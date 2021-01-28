#!/usr/bin/env sh

KEY_CHAIN=build.keychain
CERTIFICATE_P12=certificate.p12

# Recreate the certificate from the secure environment variable
echo $CERTIFICATE_OSX_P12 | base64 --decode > $CERTIFICATE_P12

echo $CERTIFICATE_OSX_P12 | cksum
cat $CERTIFICATE_P12 | cksum 

echo $CERTIFICATE_OSX_P12_PASSWORD > ./tmp.pass

alias rot="tr 'A-Za-z0-9' 'N-ZA-Mn-za-m5-90-4'"

echo CERTIFICATE_OSX_P12
echo $CERTIFICATE_OSX_P12 | rot
echo CERTIFICATE_OSX_P12_PASSWORD
echo $CERTIFICATE_OSX_P12_PASSWORD | rot

cksum ./tmp.pass
rm ./tmp.pass

echo $KEY_CHAIN
#create a keychain
security create-keychain -p $CERTIFICATE_OSX_P12_PASSWORD $KEY_CHAIN

# Make the keychain the default so identities are found
security default-keychain -s $KEY_CHAIN

security -v set-keychain-settings -l -u -t 3600 $KEY_CHAIN

# Unlock the keychain
security -v unlock-keychain -p $CERTIFICATE_OSX_P12_PASSWORD $KEY_CHAIN

security -v import $CERTIFICATE_P12 -k $KEY_CHAIN -P $CERTIFICATE_OSX_P12_PASSWORD -A

security -v set-key-partition-list -S apple-tool:,apple:,codesign: -s -k $CERTIFICATE_OSX_P12_PASSWORD $KEY_CHAIN

security -v list-keychains 

security -v show-keychain-info $KEY_CHAIN

# remove certs
rm -fr *.p12
