<br/>
<table>
	<tr>
		<th>Id</th>
		<th>Title</th>
		<th>Barcode</th>
	</tr>
	<?php foreach ($invs as $inv): ?>
	<tr>
		<td><?php echo anchor('/inv2/details/'.$inv['userId'].'/'.$inv['itemId'], $inv['userId'].'-'.$inv['itemId'])?></td>
		<td><?php echo $inv['title']?></td>
		<td><?php echo $inv['barcode']?></td>
	</tr>
	<?php endforeach ?>
</table>

