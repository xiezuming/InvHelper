<?php
class Inv_item_model extends CI_Model {
	const TABLE_ITEM = 'inv_item';
	public function get_inv_item($userId, $itemId) {
		$where = array (
				'userId' => $userId,
				'itemId' => $itemId 
		);
		$query = $this->db->get_where ( self::TABLE_ITEM, $where );
		return $query->row_array ();
	}
	public function add_inv_item($data) {
		return $this->db->insert ( self::TABLE_ITEM, $data );
	}
	public function delete_inv_itme($inv_item) {
		$where = array (
				'userId' => $inv_item ['userId'],
				'itemId' => $inv_item ['itemId'] 
		);
		$this->db->delete ( self::TABLE_ITEM, $where );
	}
}
?>