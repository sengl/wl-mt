<?php
#echo count($argv);
if (count($argv) != 3) {
	echo "Usage: php compile.php - testrun number - environment\n";
	die();
}

$testrun_number = $argv[1];
$environment = $argv[2];

$base_dir = "/home/stefan/Documents/MCI/Master/Thesis/Master Thesis/Data/";

if ($testrun_number == 1) {
    $dir = $base_dir . "1st_" . $environment;
} elseif ($testrun_number == 2) {
    $dir = $base_dir . "2nd_" . $environment;
}

/*$testrun1 = array(
	array("full-json", "schedule-bbc-one-json"),
	array("full-xml", "schedule-bbc-one-xml"),
	array("full-xhtml", "schedule-bbc-one-xhtml"),
	array("today-json", "schedule-bbc-one-20120721-json"),
	array("tomorrow-json", "schedule-bbc-one-20120722-json"),
	array("today-xml", "schedule-bbc-one-20120721-xml"),
	array("tomorrow-xml", "schedule-bbc-one-20120722-xml"),
	array("today-xhtml", "schedule-bbc-one-20120721-xhtml"),
	array("tomorrow-xhtml", "schedule-bbc-one-20120722-xhtml"),
	array("today-early-json", "schedule-bbc-one-early-20120721-json"),
	array("tomorrow-early-json", "schedule-bbc-one-early-20120722-json"),
	array("today-early-xml", "schedule-bbc-one-early-20120721-xml"),
	array("tomorrow-early-xml", "schedule-bbc-one-early-20120722-xml"),
	array("today-early-xhtml", "schedule-bbc-one-early-20120721-xhtml"),
	array("tomorrow-early-xhtml", "schedule-bbc-one-early-20120722-xhtml"),
	array("today-morning-json", "schedule-bbc-one-morning-20120721-json"),
	array("tomorrow-morning-json", "schedule-bbc-one-morning-20120722-json"),
	array("today-morning-xml", "schedule-bbc-one-morning-20120721-xml"),
	array("tomorrow-morning-xml", "schedule-bbc-one-morning-20120722-xml"),
	array("today-morning-xhtml", "schedule-bbc-one-morning-20120721-xhtml"),
	array("tomorrow-morning-xhtml", "schedule-bbc-one-morning-20120722-xhtml"),
	array("today-afternoon-json", "schedule-bbc-one-afternoon-20120721-json"),
	array("tomorrow-afternoon-json", "schedule-bbc-one-afternoon-20120722-json"),
	array("today-afternoon-xml", "schedule-bbc-one-afternoon-20120721-xml"),
	array("tomorrow-afternoon-xml", "schedule-bbc-one-afternoon-20120722-xml"),
	array("today-afternoon-xhtml", "schedule-bbc-one-afternoon-20120721-xhtml"),
	array("tomorrow-afternoon-xhtml", "schedule-bbc-one-afternoon-20120722-xhtml"),
	array("today-evening-json", "schedule-bbc-one-evening-20120721-json"),
	array("tomorrow-evening-json", "schedule-bbc-one-evening-20120722-json"),
	array("today-evening-xml", "schedule-bbc-one-evening-20120721-xml"),
	array("tomorrow-evening-xml", "schedule-bbc-one-evening-20120722-xml"),
	array("today-evening-xhtml", "schedule-bbc-one-evening-20120721-xhtml"),
	array("tomorrow-evening-xhtml", "schedule-bbc-one-evening-20120722-xhtml"),
);

$testrun2 = array(
	array("full-json", "schedule-bbc-one-json"),
	array("full-xml", "schedule-bbc-one-xml"),
	array("full-xhtml", "schedule-bbc-one-xhtml"),
	array("today-json", "schedule-bbc-one-20120721-json"),
	array("tomorrow-json", "schedule-bbc-one-20120722-json"),
	array("today-xml", "schedule-bbc-one-20120721-xml"),
	array("today-xhtml", "schedule-bbc-one-20120721-xhtml"),
	array("today-early-json", "schedule-bbc-one-early-20120721-json"),
	array("tomorrow-early-json", "schedule-bbc-one-early-20120722-json"),
	array("today-morning-json", "schedule-bbc-one-morning-20120721-json"),
	array("today-afternoon-json", "schedule-bbc-one-afternoon-20120721-json"),
	array("today-evening-json", "schedule-bbc-one-evening-20120721-json"),
	array("today-evening-xml", "schedule-bbc-one-evening-20120721-xml"),
	array("today-evening-xhtml", "schedule-bbc-one-evening-20120721-xhtml"),
);*/

$compiled = array(
	array("media_type", "environment", "resource_data", "sub_resource_day", "sub_resource_daytime", "request_rate_demanded", "request_rate", "min_reply_rate", "avg_reply_rate", "max_reply_rate", "stddev_reply_rate", "avg_response_time", "avg_net_io", "error_rate", "sample_count_reply_rate", "duration"),
);

function recursiveIterateDirectory($directory, &$compiled, $environment = "") {
    $directoryIterator = new RecursiveDirectoryIterator($directory);
    foreach ($directoryIterator as $file) {
        if ($file == $directory . "/warmup") {
            continue;
        }
        if ($directoryIterator->hasChildren()) {
            recursiveIterateDirectory($directoryIterator->getChildren()->getPath(), $compiled, $environment);
        }
        if ($directoryIterator->isDot()) {
            continue;
        }
        
        #echo "Getting data from " . $file . "\n";
        $filename = (string) $file;
        $pathname = $directoryIterator->getPathname();
        if (strpos($filename, ".csv")) {
            echo "Getting data from " . $file . "\n";
            $handle = fopen($file, 'r');
            $line = array();
            for ($i = 0; $i<=15; $i++) {
                $line[$i] = null;
            }
            while (($data = fgetcsv($handle)) !== FALSE) {
                if ($data[0] == "dem_req_rate") {
                    continue;
                }
                
                // media_type
                if (strpos($pathname, "json")) {
                    $line[0] = "1";
                } elseif (strpos($pathname, "xml")) {
                    $line[0] = "2";
                } elseif (strpos($pathname, "xhtml")) {
                    $line[0] = "3";
                } else {
                    $line[0] = "";
                }
                
                // environment
                if ($environment == "wsmt1m") {
                    $line[1] = "1";
                } elseif ($environment == "wsmt2m") {
                    $line[1] = "2";
                } elseif ($environment == "wsmt4m") {
                    $line[1] = "3";
                } else {
                    $line[1] = "";
                }
                
                // resource_data, sub_resource_day, sub_resource_daytime
                $line[2] = "";
                $line[3] = "0";
                $line[4] = "0";
                if (strpos($pathname, "full")) {
                    $line[2] = "1";
                }
                if (strpos($pathname, "early")) {
                    $line[2] = "3";
                    $line[4] = "1";
                }
                if (strpos($pathname, "morning")) {
                    $line[2] = "3";
                    $line[4] = "2";
                }
                if (strpos($pathname, "afternoon")) {
                    $line[2] = "3";
                    $line[4] = "3";
                }
                if (strpos($pathname, "evening")) {
                    $line[2] = "3";
                    $line[4] = "4";
                }
                if (strpos($pathname, "today")) {
                    if($line[2] == "") {
                        $line[2] = "2";
                    }
                    $line[3] = "1";
                }
                if (strpos($pathname, "tomorrow")) {
                    if($line[2] == "") {
                        $line[2] = "2";
                    }
                    $line[3] = "2";
                }
                
                // request_rate_demanded
                $line[5] = str_replace(".", ",", $data[0]);
                // request_rate
                $line[6] = str_replace(".", ",", $data[1]);
                // min_reply_rate
                $line[7] = str_replace(".", ",", $data[2]);
                // avg_reply_rate
                $line[8] = str_replace(".", ",", $data[3]);
                // max_reply_rate
                $line[9] = str_replace(".", ",", $data[4]);
                // stddev_reply_rate
                $line[10] = str_replace(".", ",", $data[5]);
                // avg_response_time
                $line[11] = str_replace(".", ",", $data[6]);
                // avg_net_io
                $line[12] = str_replace(".", ",", $data[7]);
                // error_rate
                $line[13] = str_replace(".", ",", $data[8]);
                // sample_count_reply_rate
                $line[14] = "59";
                // duration
                $line[15] = "300,000";
                
                $compiled[] = $line;
            }
            fclose($handle);
        }
    }
}

recursiveIterateDirectory($dir, $compiled, $environment);

$handle = fopen($dir . "_output.csv", 'w');

foreach ($compiled as $fields) {
    fputcsv($handle, $fields, ";");
}

fclose($handle);