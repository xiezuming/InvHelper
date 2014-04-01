<br/>

<table>
	<tr>
		<th>Id</th>
		<th>Title</th>
		<th>Barcode</th>
	</tr>
	<tr>
		<td><?php echo $inv['userId'].'-'.$inv['itemId']?></td>
		<td><?php echo $inv['title']?></td>
		<td><?php echo $inv['barcode']?></td>
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
	<?php foreach ($match_items as $item): ?>
	<tr>
		<td><input type="button" value="Link" onclick='link("<?php echo $item['url']?>")'></td>
		<td><?php echo anchor($item['url'], $item['title'], 'target="_blank"')?></td>
		<td><?php echo $item['price']?></td>
		<td><img src="<?php echo $item['image']?>" height="200"></td>
	</tr>
	<?php endforeach ?>
</table>

<script type="text/javascript">
function link(url)
{
	document.getElementById("link_url").value = url;
	document.forms["myform"].submit();
}
</script>
