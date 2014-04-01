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
		$data['invs'] = $this->inv_item_model->get_inv_list();
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
		// Mock data
		/*$data['match_items'] = array(
			1	=>	array(
				"title"		=>	"Garmin forerunner 620 gps fitness computer black / blue train wristwatch watch",
				"url"		=>	"http://www.ebay.com/itm/Garmin-forerunner-620-gps-fitness-computer-black-blue-train-wristwatch-watch-/151210376553?pt=LH_DefaultDomain_0&hash=item2334d73d69",
				"price"		=>	'399.99',
				"image"		=>	'http://i.ebayimg.com/00/s/NjQwWDQ2Ng==/z/haMAAOxyXDhSojfU/$_3.JPG'
			),
			2	=>	array(
				"title"		=>	"Xiaomi RED RICE Hongmi Android 4.2 Quad Core 1.5G 1G RAM Dual Sim 3G Smartphone",
				"url"		=>	"http://www.ebay.com/itm/Xiaomi-RED-RICE-Hongmi-Android-4-2-Quad-Core-1-5G-1G-RAM-Dual-Sim-3G-Smartphone-/151239857913?pt=Cell_Phones&hash=item23369916f9",
				"price"		=>	'218.28',
				"image"		=>	'http://i.ebayimg.com/00/s/ODAwWDgwMA==/z/afYAAOxy-WxTCwL6/$_3.JPG'
			),
		);
		*/
		
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
