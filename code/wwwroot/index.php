<?php

xhprof_enable(XHPROF_FLAGS_CPU | XHPROF_FLAGS_MEMORY | XHPROF_FLAGS_NO_BUILTINS);



header('Content-Type: text/html', true);

echo  <<<RESPONSE
<!DOCTYPE html>
<html>
<head>
	<link rel="icon" href="data:;base64,iVBORw0KGgo=">
	<link rel="stylesheet" type="text/css" href="/css/style.css" media="screen">
	<title>HW</title>
</head>
<body>
	<h4>Hello World!</h4>
</body>
</html>
RESPONSE;



$profilerNamespace = 'bahis_m';
$xhprofData = xhprof_disable();

include_once "/xhprof/xhprof_lib/utils/xhprof_lib.php";
include_once "/xhprof/xhprof_lib/utils/xhprof_runs.php";

$xhprofRuns = new XHProfRuns_Default();
$runId = $xhprofRuns->save_run($xhprofData, $profilerNamespace);

