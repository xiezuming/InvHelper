<br/>
<?php echo anchor('/inv2', 'Back')?>
<table>
	<tr>
		<th>Id</th>
		<th>Title</th>
		<th>Barcode</th>
		<th>Photo</th>
	</tr>
	<tr>
		<td><?php echo $inv['userId'].'-'.$inv['itemId']?></td>
		<td><?php echo $inv['title']?></td>
		<td><?php echo $inv['barcode']?></td>
		<td>
		<?php 
		if ($inv['photoname1']) {
			$url_orignal = site_url('/inv2/image_orignal/'.$inv['userId'].'/'.$inv['photoname1']);
			$url_thumbnail = site_url('/inv2/image_thumbnail/'.$inv['userId'].'/'.$inv['photoname1']);
			echo '<a href="'.$url_orignal.'" target="_blank"><img src="'.$url_thumbnail.'"/></a>';
		}
		if ($inv['photoname2']) {
			$url_orignal = site_url('/inv2/image_orignal/'.$inv['userId'].'/'.$inv['photoname2']);
			$url_thumbnail = site_url('/inv2/image_thumbnail/'.$inv['userId'].'/'.$inv['photoname2']);
			echo '<a href="'.$url_orignal.'" target="_blank"><img src="'.$url_thumbnail.'"/></a>';
		}
		if ($inv['photoname3']) {
			$url_orignal = site_url('/inv2/image_orignal/'.$inv['userId'].'/'.$inv['photoname3']);
			$url_thumbnail = site_url('/inv2/image_thumbnail/'.$inv['userId'].'/'.$inv['photoname3']);
			echo '<a href="'.$url_orignal.'" target="_blank"><img src="'.$url_thumbnail.'"/></a>';
		}
		?>
		</td>
	</tr>
</table>
<hr/>
<?php echo form_open('/inv2/link/'.$inv['userId'].'/'.$inv['itemId'], 'id="myform"') ?>
	<input id="link_url" name='link_url' type="hidden"/>
<?php echo '</form>' ?>

<table>
	<tr>
		<th></th>
		<th>Title</th>
		<th>Price</th>
		<th>Image</th>
	</tr>
	<?php
	if ($match_items && is_array($match_items)) {
		foreach ($match_items as $item): ?>
	<tr>
		<td><input type="button" value="Link" onclick='link("<?php echo $item['url']?>")'></td>
		<td><?php echo anchor($item['url'], $item['title'], 'target="_blank"')?></td>
		<td><?php echo $item['price']?></td>
		<td><img src="<?php echo $item['image']?>" height="200"></td>
	</tr>
	<?php 
		endforeach;
	} ?>
</table>

<script type="text/javascript">
function link(url)
{
	document.getElementById("link_url").value = url;
	document.forms["myform"].submit();
}
</script>
