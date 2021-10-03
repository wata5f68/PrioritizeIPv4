$IPV4_PREFIX = "::ffff:0:0/96"
$ADD_PRECEDENCE_NUM = 10
$NetPrefixPolicies = Get-NetPrefixPolicy
$tmp = 0 

foreach( $NetPrefixPolicy in $NetPrefixPolicies ){
    if($NetPrefixPolicy.Precedence -gt $tmp){
        $tmp = $NetPrefixPolicy.Precedence
    }
}

$HighestPrecedence = $tmp
$IPv4Info = ($NetPrefixPolicies | Where-Object{ $_.Prefix -eq $IPV4_PREFIX })
$NewHighestPrecedence  = [int]$HighestPrecedence + $ADD_PRECEDENCE_NUM


if( $HighestPrecedence -ne $IPv4Info.Precedence ){
    echo "変更後のIPv4のPrecedenceは$NewHighestPrecedence"
    echo "変更を開始します"
    netsh interface ipv6 set prefixpolicy $IPV4_PREFIX $NewHighestPrecedence $IPv4Info.Label
    foreach( $NetPrefixPolicy in $NetPrefixPolicies ){
        if( $NetPrefixPolicy.Prefix -ne $IPV4_PREFIX ){
            netsh interface ipv6 set prefixpolicy $NetPrefixPolicy.Prefix $NetPrefixPolicy.Precedence $NetPrefixPolicy.Label
        }
    }
}else {
    echo "IPv4のPrecedenceが最も高いため変更しませんでした"
}