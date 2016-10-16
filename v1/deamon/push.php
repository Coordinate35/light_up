<?php

function push($redis, $channel, $message)
{
	echo $message;
}

$redis = new Redis();
$redis->connect("127.0.0.1", 6379);

$redis->subscribe(array('light_last_light'), 'push');