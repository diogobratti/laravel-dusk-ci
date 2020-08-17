<?php
$compatibility = [
    '85.0.4183.38' => '85',
    '84.0.4147.30' => '84',
    '83.0.4103.39' => '83',
    '83.0.4103.14' => '83',
    '81.0.4044.138' => '81',
    '81.0.4044.69' => '81',
    '81.0.4044.20' => '81',
    '80.0.3987.106' => '80',
    '80.0.3987.16' => '80',
    '79.0.3945.36' => '79',
    '79.0.3945.16' => '79',
    '78.0.3904.105' => '78',
    '78.0.3904.70' => '78',
    '78.0.3904.11' => '78',
    '77.0.3865.40' => '77',
    '77.0.3865.10' => '77',
    '76.0.3809.126' => '76',
    '76.0.3809.68' => '76',
    '76.0.3809.25' => '76',
    '76.0.3809.12' => '76',
    '75.0.3770.140' => '75',
    '75.0.3770.90' => '75',
    '75.0.3770.8' => '75',
    '74.0.3729.6' => '74',
    '73.0.3683.68' => '73',
    '73.0.3683.20' => '73',
    '2.46' => '71-73',
    '2.45' => '70-72',
    '2.44' => '69-71',
    '2.43' => '69-71',
    '2.42' => '68-70',
    '2.41' => '67-69',
    '2.40' => '66-68',
    '2.39' => '66-68',
    '2.38' => '65-67',
    '2.37' => '64-66',
    '2.36' => '63-65',
    '2.35' => '62-64',
    '2.34' => '61-63',
    '2.33' => '60-62'
];
$compatibilityMatrix = [];
foreach ($compatibility as $driver => $chrome) {
    $chromeversions_temp = explode('-',$chrome);
    if (count($chromeversions_temp)>1) {
        $beginning = $chromeversions_temp[0];
        $end = $chromeversions_temp[1];
    } else {
        $beginning = $chrome;
        $end = $chrome;
    }
    for ($i=$beginning; $i<=$end ; $i++){
        array_push($compatibilityMatrix, [$driver, intval($i)]);
    }
}
