<?php
if (! defined ( 'BASEPATH' ))
	exit ( 'No direct script access allowed' );
const SUCCESS = 1;
const FAILURE = 0;
const UPLOAD_BASE_PATH = '/var/uploads/';

/**
 *
 * @property Inv_item_model $inv_item_model
 * @property Inv_user_model $inv_user_model
 */
class Inv extends CI_Controller {
	function __construct() {
		parent::__construct ();
		$this->load->model ( 'inv_item_model' );
		$this->load->model ( 'inv_user_model' );
	}
	public function get_user() {
		$user = $this->inv_user_model->get_user ( $this->input->post ( 'userName' ) );
		if ($user) {
			unset ( $user ['password'] );
			$data ['result'] = SUCCESS;
			$data ['data'] = $user;
		} else {
			$data ['result'] = FAILURE;
			$data ['message'] = 'The user does not exist.';
		}
		
		echo json_encode ( $data );
	}
	public function add_item() {
		$input_data = $this->get_input_data ();
		$inv_item = $this->inv_item_model->get_inv_item ( $input_data ['userId'], $input_data ['itemId'] );
		if ($inv_item) {
			$this->inv_item_model->delete_inv_itme ( $inv_item );
			
			$path = UPLOAD_BASE_PATH . $inv_item ['userId'] . '/';
			if ($inv_item ['photoname1'])
				$this->delete_file ( $path . $inv_item ['photoname1'] );
			if ($inv_item ['photoname2'])
				$this->delete_file ( $path . $inv_item ['photoname2'] );
			if ($inv_item ['photoname3'])
				$this->delete_file ( $path . $inv_item ['photoname3'] );
		}
		$data ['result'] = $this->inv_item_model->add_inv_item ( $input_data ) ? SUCCESS : FAILURE;
		
		echo json_encode ( $data );
	}
	private function delete_file($file_path) {
		if (file_exists ( $file_path )) {
			unlink ( $file_path );
		}
	}
	public function add_item_page() {
		$this->load->helper ( 'form' );
		$this->load->library ( 'form_validation' );
		
		$data ['field_names'] = $this->get_field_names ();
		$this->load->view ( 'inv/add_form', $data );
	}
	function upload($userId = 0) {
		if ($userId == 0) {
			$userId = $this->input->post ( 'userId' );
		}
		$upload_path = UPLOAD_BASE_PATH . $userId;
		if (! file_exists ( $upload_path )) {
			mkdir ( $upload_path );
		}
		
		$config ['upload_path'] = $upload_path;
		$config ['allowed_types'] = 'gif|jpg|png';
		$config ['max_size'] = '1024';
		$config ['overwrite'] = TRUE;
		
		$this->load->library ( 'upload', $config );
		if ($this->upload->do_upload ()) {
			$data ['result'] = SUCCESS;
			$data ['data'] = $this->upload->data ();
		} else {
			$data ['result'] = FAILURE;
			$data ['message'] = $this->upload->display_errors ();
		}
		
		echo json_encode ( $data );
	}
	public function upload_page() {
		$this->load->helper ( 'form' );
		
		$this->load->view ( 'inv/upload_form', array (
				'error' => ' ' 
		) );
	}
	private function get_field_names() {
		$field_names = array (
				"userId" => "userId",
				"itemId" => "itemId",
				"title" => "title",
				"barcode" => "barcode",
				"category" => "category",
				"condition" => "condition",
				"price" => "price",
				"quantity" => "quantity",
				"size" => "size",
				"weight" => "weight",
				"latitude" => "latitude",
				"longitude" => "longitude",
				"desc" => "desc",
				"photoname1" => "photoname1",
				"photoname2" => "photoname2",
				"photoname3" => "photoname3",
				"createDate" => "createDate",
				"updateDate" => "updateDate" 
		);
		return $field_names;
	}
	private function get_input_data() {
		$input_data = array ();
		foreach ( $this->get_field_names () as $field_name ) {
			$field_value = $this->input->post ( $field_name );
			if (empty ( $field_value )) {
				$input_data [$field_name] = NULL;
			} else {
				// change
				if ($this->endsWith ( $field_name, 'Date' )) {
					$field_value = date ( 'Y-m-d H:i:s', $field_value );
				}
				$input_data [$field_name] = $field_value;
			}
		}
		return $input_data;
	}
	private function endsWith($haystack, $needle) {
		return $needle === "" || substr ( $haystack, - strlen ( $needle ) ) === $needle;
	}
}

?>
