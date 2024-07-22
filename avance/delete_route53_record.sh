#!/bin/sh

read -p "HOSTED_ZONE_ID: " HOSTED_ZONE_ID
read -p "SUDENT_NUMBER: " SUDENT_NUMBER

DNS_NAME="app2.student-${SUDENT_NUMBER}.com"
APP2_IP="10.0.0.2"
RECORD_TYPE="A"
TTL="300"

JSON_FILE=`mktemp`

(
cat <<EOF
{
    "Comment": "Delete single record set",
    "Changes": [
        {
            "Action": "DELETE",
            "ResourceRecordSet": {
                "Name": "$DNS_NAME.",
                "Type": "$RECORD_TYPE",
                "TTL": $TTL,
                "ResourceRecords": [
                    {
                        "Value": "${APP2_IP}"
                    }
                ]
            }
        }
    ]
}
EOF
) > $JSON_FILE

echo "Deleting DNS Record set"
aws route53 change-resource-record-sets --hosted-zone-id ${HOSTED_ZONE_ID} --change-batch file://$JSON_FILE

echo "Deleting record set ..."
echo
echo "Operation Completed."
