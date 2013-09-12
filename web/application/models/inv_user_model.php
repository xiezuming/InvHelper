<?php
Class Inv_user_model extends CI_Model
{
	const TABLE_USER = 'inv_user';

	public function get_user($userName)
	{
		$where = array('userName' => $userName);
		$query = $this->db->get_where(self::TABLE_USER, $where);
		return $query->row_array();
	}
	
}
?>