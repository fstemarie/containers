<?php
require_once('plugins/login-servers.php');
return new AdminerLoginServers([
    'PostgreSQL' => ['server' => 'db:5432', 'driver' => 'pgsql']
]);