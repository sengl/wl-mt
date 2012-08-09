<?php
// check if needed command line arguments are supplied
if (count($argv) != 3) {
	echo "Usage: php compile.php - testrun number - environment\n";
	die();
}

// get command line arguments
$testrun_number = $argv[1];
$environment = $argv[2];

// local base directory that contains the test results
$base_dir = "/home/stefan/Documents/MCI/Master/Thesis/Master Thesis/Data/";

// build directory for iteration, based on testrun and environment
if ($testrun_number == 1) {
    $dir = $base_dir . "1st_" . $environment;
} elseif ($testrun_number == 2) {
    $dir = $base_dir . "2nd_" . $environment;
}

// compiled output file first line array
$compiled = array(
	array("media_type", "environment", "resource_data", "sub_resource_day", "sub_resource_daytime", "request_rate_demanded", "request_rate", "min_reply_rate", "avg_reply_rate", "max_reply_rate", "stddev_reply_rate", "avg_response_time", "avg_net_io", "error_rate", "sample_count_reply_rate", "duration"),
);

// recursively iterate over directory and add each result case to the compiled output file
function recursiveIterateDirectory($directory, &$compiled, $environment = "") {
    $directoryIterator = new RecursiveDirectoryIterator($directory);
    foreach ($directoryIterator as $file) {
        // ignore the warump results
        if ($file == $directory . "/warmup") {
            continue;
        }
        // if current iterator is a directory call the recursive function with the current iterator
        if ($directoryIterator->hasChildren()) {
            recursiveIterateDirectory($directoryIterator->getChildren()->getPath(), $compiled, $environment);
        }
        // ignore "." and ".."
        if ($directoryIterator->isDot()) {
            continue;
        }
        // typecast filename to string
        $filename = (string) $file;
        // get current path including filename
        $pathname = $directoryIterator->getPathname();
        // only process the csv result files
        if (strpos($filename, ".csv")) {
            echo "Getting data from " . $file . "\n";
            // build and initialize the the line-array to add to the compiled file
            $line = array();
            for ($i = 0; $i<=15; $i++) {
                $line[$i] = null;
            }
            // open the file with read permissions
            $handle = fopen($file, 'r');
            // iterate over the lines of the opened file
            while (($data = fgetcsv($handle)) !== FALSE) {
                // skip first line
                if ($data[0] == "dem_req_rate") {
                    continue;
                }
                
                // insert media_type
                if (strpos($pathname, "json")) {
                    $line[0] = "1";
                } elseif (strpos($pathname, "xml")) {
                    $line[0] = "2";
                } elseif (strpos($pathname, "xhtml")) {
                    $line[0] = "3";
                } else {
                    $line[0] = "";
                }
                
                // insert environment
                if ($environment == "wsmt1m") {
                    $line[1] = "1";
                } elseif ($environment == "wsmt2m") {
                    $line[1] = "2";
                } elseif ($environment == "wsmt4m") {
                    $line[1] = "3";
                } else {
                    $line[1] = "";
                }
                
                // insert resource_data, sub_resource_day and sub_resource_daytime
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
                
                // insert request_rate_demanded
                $line[5] = str_replace(".", ",", $data[0]);
                // insert request_rate
                $line[6] = str_replace(".", ",", $data[1]);
                // insert min_reply_rate
                $line[7] = str_replace(".", ",", $data[3]);
                // insert avg_reply_rate
                $line[8] = str_replace(".", ",", $data[4]);
                // insert max_reply_rate
                $line[9] = str_replace(".", ",", $data[5]);
                // insert stddev_reply_rate
                $line[10] = str_replace(".", ",", $data[6]);
                // insert avg_response_time
                $line[11] = str_replace(".", ",", $data[7]);
                // insert avg_net_io
                $line[12] = str_replace(".", ",", $data[8]);
                // insert error_rate
                $line[13] = str_replace(".", ",", $data[9]);
                // insert sample_count_reply_rate
                $line[14] = "59";
                // insert duration
                $line[15] = "300,000";
                
                // add line to compiled output 
                $compiled[] = $line;
            }
            // close the file
            fclose($handle);
        }
    }
}

// recursively iterate over defined directory
recursiveIterateDirectory($dir, $compiled, $environment);

// open/create the output file with write permissions
$handle = fopen($dir . "_output.csv", 'w');

// add each line of compiled array to the csv output file
foreach ($compiled as $fields) {
    fputcsv($handle, $fields, ";");
}

// close the output file
fclose($handle);
