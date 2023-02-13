> Android activity manager.
> More information: <https://developer.android.com/studio/command-line/adb#am>.

- Start a specific activity:

`am start -n {string activity: com.android.settings/.Settings}`

- Start an activity and pass [d]ata to it:

`am start -a {string activity: android.intent.action.VIEW} -d {string data: tel:123}`
