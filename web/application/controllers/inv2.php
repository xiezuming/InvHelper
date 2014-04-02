<?php
if (! defined ( 'BASEPATH' ))
	exit ( 'No direct script access allowed' );
const SUCCESS = 1;
const FAILURE = 0;
const UPLOAD_BASE_PATH = '/var/uploads/';
const THUMBNAILS_BASE_PATH = '/var/uploads/thumbnails/';

/**
 *
 * @property Inv_item_model $inv_item_model
 * @property Inv_user_model $inv_user_model
 * @property Inv_recommendation_model $inv_recommendation_model
 */
class Inv2 extends CI_Controller {
	function __construct() {
		parent::__construct ();
		$this->load->model ( 'inv_item_model' );
		$this->load->model ( 'inv_user_model' );
		$this->load->model ( 'inv_recommendation_model' );
	}
	
	public function index()
	{
		$where = "inv_item.itemId <> 3";
		$data['invs'] = $this->inv_item_model->get_available_inv_list($where);
		$data['count'] = $this->inv_item_model->count_available_inv_list($where);
		$data['title'] = 'Inv List';

		$this->load->view('templates/header', $data);
		$this->load->view('inv2/index', $data);
		$this->load->view('templates/footer');
	}
	
	public function details($userId, $itemId)
	{
		$data['inv'] = $this->inv_item_model->get_inv_item($userId, $itemId);
		if (empty($data['inv']))
		{
			show_404();
		}
		$data['title'] = 'Inv Details';
		
		$data['match_items'] = $this->call_query_items_script($data['inv']['title']);
		
		$this->load->helper('form');
		
		$this->load->view('templates/header', $data);
		$this->load->view('inv2/details', $data);
		$this->load->view('templates/footer');
	}
	
	public function link($userId, $itemId)
	{
		$link_url = $this->input->post ( 'link_url' );
		// Call python script. Link the inventory item with eBay item url
		$result = $this->call_link_script($userId, $itemId, $link_url);
		
		if (isset($result)) {
			$this->session->set_flashdata('falshmsg',
					array('type'=>'error', 'content'=>'Failed to link. <br/>'.$result));
			redirect(site_url("/inv2/details/".$userId.'/'.$itemId), 'refresh');
		} else {
			$this->session->set_flashdata('falshmsg',
					array('type'=>'message', 'content'=>'Item['.$userId.'-'.$itemId.'] is linked. <br/>'.$link_url));
			redirect(site_url("/inv2/"), 'refresh');
		}
	}
	
	public function image_orignal($userId, $file_name)
	{
		$orignal_file_path = UPLOAD_BASE_PATH . $userId . DIRECTORY_SEPARATOR . $file_name;
		$this->image($orignal_file_path);
	}
	
	public function image_thumbnail($userId, $file_name)
	{
		$orignal_file_path = UPLOAD_BASE_PATH . $userId . DIRECTORY_SEPARATOR . $file_name;
		if (!file_exists($orignal_file_path)) {
			show_404();
		}
		
		// create floder
		$thumbnail_folder_path = THUMBNAILS_BASE_PATH . $userId;
		if (! file_exists ( $thumbnail_folder_path )) {
			mkdir ( $thumbnail_folder_path, 0777, TRUE );
		}
		
		$thumbnail_file_path = THUMBNAILS_BASE_PATH . $userId . DIRECTORY_SEPARATOR . $file_name;
		if (!file_exists($thumbnail_file_path)) {
			// create thumbnail
			$orig_img = imagecreatefromjpeg($orignal_file_path);
			
			$info = getimagesize($orignal_file_path);
			$width = $info[0];
			$height = $info[1];
			$newWidth = 100;
			$newHeight = ($height / $width) * $newWidth;
			$thumbnail_img = imagecreatetruecolor($newWidth, $newHeight);
			
			imagecopyresampled($thumbnail_img, $orig_img, 0, 0, 0, 0, $newWidth, $newHeight, $width, $height);
			imagejpeg($thumbnail_img, $thumbnail_file_path);
		}

		$this->image($thumbnail_file_path);
	}
	
	private function image($file_path)
	{
		if (!file_exists($file_path)) {
			show_404();
		}
		
		header('Content-Length: '.filesize($file_path)); //<-- sends filesize header
		header('Content-Type: image/jpg'); //<-- send mime-type header
		header('Content-Disposition: inline; filename="'.$file_path.'";'); //<-- sends filename header
		readfile($file_path); //<--reads and outputs the file onto the output buffer
		die(); //<--cleanup
		exit; //and exit
	}
	
	private function call_query_items_script($title)
	{
		$data = array($title);
		$cmd = FCPATH . 'scripts' . DIRECTORY_SEPARATOR . 'query_matched_items.py';
		$result = shell_exec('python ' . $cmd . ' ' . escapeshellarg(json_encode($data)));
		$result = json_decode($result, true);
		return $result;
	}
	
	private function call_link_script($userId, $itemId, $link_url)
	{
		$data = array($userId, $itemId, $link_url);
		$cmd = FCPATH . 'scripts' . DIRECTORY_SEPARATOR . 'link_item.py';
		$result = shell_exec('python ' . $cmd . ' ' . escapeshellarg(json_encode($data)));
		return $result;
	}
}

?>
