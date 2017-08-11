$ SET FILE/ATTRIBUTEs=RFM=STM
$! Original code created by Dan Leib
$ cd dk0:[MICROCT.DATA.00006872.00025390]
$ ipl
/isq_to_aim in C0024374.isq 0 -1
/todicom_from_aim in 00025390.dcm true false
q
$ EXIT
