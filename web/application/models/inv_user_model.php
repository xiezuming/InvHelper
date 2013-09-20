<?php
class Inv_user_model extends CI_Model {
	const TABLE_USER = 'inv_user';
	public function create_user($userName, $password) {
		$data = array (
				'userName' => $userName,
				'password' => md5 ( $password ) 
		);
		$this->db->insert ( self::TABLE_USER, $data );
		return $this->db->insert_id ();
	}
	public function login($userName, $password) {
		$where = array (
				'userName' => $userName,
				'password' => md5 ( $password ) 
		);
		$query = $this->db->get_where ( self::TABLE_USER, $where );
		$user = $query->row_array ();
		if ($user) {
			$data = array (
					'token' => $this->rand_string ( 32 ) 
			);
			$this->db->where ( 'userId', $user ['userId'] );
			$this->db->update ( self::TABLE_USER, $data );
			$data ['userId'] = $user ['userId'];
			return $data;
		}
		return NULL;
	}
	public function logout($userId) {
		$data = array (
				'token' => NULL 
		);
		$this->db->where ( 'userId', $userId );
		$this->db->update ( self::TABLE_USER, $data );
	}
	public function check_user($userId, $token) {
		$where = array (
				'userId' => $userId,
				'token' => $token 
		);
		$query = $this->db->get_where ( self::TABLE_USER, $where );
		
		return ($query->row_array () == NULL);
	}
	function rand_string($length) {
		$chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
		
		$size = strlen ( $chars );
		$str = '';
		for($i = 0; $i < $length; $i ++) {
			$str .= $chars [rand ( 0, $size - 1 )];
		}
		
		return $str;
	}
}
?>