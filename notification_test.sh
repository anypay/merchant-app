
# DATA='{"notification": {"body": "Testing notifications","title": "Test"}, "priority": "high", "data": {"click_action": "FLUTTER_NOTIFICATION_CLICK", "id": "1", "path" : "/settings/addresses", "status": "done"}, "to": "<Device Token>"}'
# curl https://fcm.googleapis.com/fcm/send -H "Content-Type:application/json" -X POST -d "$DATA" -H "<Server Key>"



DATA='{"notification": {"body": "Testing notifications","title": "Test"}, "priority": "high", "data": {"click_action": "FLUTTER_NOTIFICATION_CLICK", "id": "1", "path" : "/settings/addresses", "status": "done"}, "to": "fWCaTJiJqZg:APA91bGcpSDoVhQsY0jIMY_QBryWSstvFFEQyCjdNahYKfRyf-Mc5Pw7BT6T6NrfSXl_nH4fW3aO99T7aMJFjl2ocfvq11Su-vtIn-wPU8uXoyZaEPCLkPlSRiEzzxPhVotm89PODNLS"}'
curl https://fcm.googleapis.com/fcm/send -H "Content-Type:application/json" -X POST -d "$DATA" -H "Authorization: key=AAAASInirpw:APA91bElAjD3VsNh-9fUr-XSh56NiXbjWZnObsKV30ZC5ZNpDIOdqKqpcWvENkZ1pX7GthJcLEPq2Nzy6K-zBiZTyXo7gm-WKpKngZWtDEXebQPjrsXhesiAoQTGunNaKCNUMBNehjlH"
