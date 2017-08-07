$data = Import-Csv -Delimiter ";" -Path "$PSScriptRoot\data.csv" | select -First 12
$num_of_pay = ($data | Measure-Object).Count
$config = Import-Csv -Delimiter "," -Path "$PSScriptRoot\config.csv"

$begining = "<?xml version=`"1.0`" encoding=`"UTF-8`"?>
    <Document xmlns=`"urn:iso:std:iso:20022:tech:xsd:pain.001.001.03`" xmlns:xsi=`"http://www.w3.org/2001/XMLSchema-instance`" xsi:schemaLocation=`"urn:iso:std:iso:20022:tech:xsd:pain.001.001.03 pain.001.001.03.xsd`">
    <CstmrCdtTrfInitn>
    <GrpHdr>
    <MsgId>MSG0001</MsgId>
    <CreDtTm>2017-07-18T12:01:10</CreDtTm>
    <NbOfTxs>$num_of_pay</NbOfTxs>
    <InitgPty />
    </GrpHdr>"
$end = "</CstmrCdtTrfInitn>
</Document>"

Write-Output $begining | Out-File -FilePath "$PSScriptRoot\paym.xml" -Encoding unicode
$nr = 1
foreach ($entry in $data) {
    $date = $(get-date $entry.date)
    $paym_date = $date.AddDays(-2).ToShortDateString()
    $desc_date = "$(($date.AddMonths(-1)).Year)" + "_" + "$(($date.AddMonths(-1)).month)"
    $paym = "		<PmtInf>
			<PmtInfId>$("000"+$nr)</PmtInfId>
			<PmtMtd>TRF</PmtMtd>
			<ReqdExctnDt>$paym_date</ReqdExctnDt>
			<Dbtr>
				<Nm>$($config.sender)</Nm>
			</Dbtr>
			<DbtrAcct>
				<Id>
					<IBAN>$($config.sender_IBAN)</IBAN>
				</Id>
			</DbtrAcct>
			<DbtrAgt>
				<FinInstnId />
			</DbtrAgt>
			<CdtTrfTxInf>
				<PmtId>
					<EndToEndId>number_$nr</EndToEndId>
				</PmtId>
				<Amt>
					<InstdAmt Ccy=`"EUR`">$($entry.half.Replace(",","."))</InstdAmt>
				</Amt>
				<Cdtr>
					<Nm>$($config.receiver)</Nm>
				</Cdtr>
				<CdtrAcct>
					<Id>
						<IBAN>$($config.receiver_IBAN)</IBAN>
					</Id>
				</CdtrAcct>
				<RmtInf>
					<Ustrd>$($config.payment_description)_$desc_date</Ustrd>
				</RmtInf>
			</CdtTrfTxInf>
		</PmtInf>"
    Write-Output $paym | Out-File -FilePath "$PSScriptRoot\paym.xml" -Append
    $nr++
}

Write-Output $end | Out-File -FilePath "$PSScriptRoot\paym.xml" -Append
