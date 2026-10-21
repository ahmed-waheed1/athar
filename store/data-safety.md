# Play Console: Data safety answers

Answers for **App content → Data safety** in Play Console, for Athar 1.0.0 (com.ahmedwaheed.athar).

Why these answers hold: everything is stored on the device (Hive for habits, SharedPreferences for settings). The release manifest has no `INTERNET` permission, and the app includes no analytics, ads, crash-reporting, or account SDKs. Google defines "collect" as transmitting data off the device, and data processed only on the device doesn't count, so Athar collects nothing.

Recheck these answers whenever you add a dependency or a permission.

---

## Section 1: Data collection and security

| Question | Answer |
|---|---|
| Does your app collect or share any of the required user data types? | **No** |

Answering **No** skips the encryption, deletion, and data-type sections. Play then shows on the listing: *"No data collected"* and *"No data shared with third parties"*.

If the form still asks the follow-ups, use these:

| Question | Answer |
|---|---|
| Is all of the user data collected by your app encrypted in transit? | Not applicable, no data leaves the device |
| Do you provide a way for users to request that their data is deleted? | Users delete everything in-app with **Settings → Reset all data**, or by uninstalling. There are no accounts and no server copy. |

## Section 2: Data types

Leave every data type unchecked: Location, Personal info, Financial info, Health and fitness, Messages, Photos and videos, Audio, Files and docs, Calendar, Contacts, App activity, Web browsing, App info and performance, Device or other IDs.

Habit names and check-offs never leave the device, so they are not "collected" under Play's definition.

## Section 3: Related declarations elsewhere in App content

| Item | Answer |
|---|---|
| Privacy policy URL | Required even with no data collected. Host `store/privacy-policy.md` at a public URL (for example GitHub Pages) and paste the link. |
| Ads | **No**, the app does not contain ads |
| App access | **All functionality is available without special access** (no login) |
| Account deletion | Not applicable, the app has no accounts |
| Target audience and content | Choose 13+ or 18+ (avoids the Families policy requirements). The app suits all ages, but choosing under-13 audiences adds extra review. |
| Content rating (IARC questionnaire) | Category: Utility/Productivity. Answer **No** to violence, sexual content, language, controlled substances, gambling, user interaction/communication, sharing location, and digital purchases. Expected rating: Everyone / PEGI 3. |
| Government app / Financial features / Health | No / No features / Not a health app |
| News app | No |

## Permissions in the release manifest (for reference)

| Permission | Why |
|---|---|
| `POST_NOTIFICATIONS` | Habit reminders, requested only after the in-app explanation sheet |
| `RECEIVE_BOOT_COMPLETED` | Re-schedules reminders after the phone restarts |
| `VIBRATE` | Added by flutter_local_notifications; reminder vibration |
| `com.ahmedwaheed.athar.DYNAMIC_RECEIVER_NOT_EXPORTED_PERMISSION` | Added by AndroidX; signature-level, internal to the app |

Checked against the merged release manifest (build/app/intermediates/merged_manifests/release): no `INTERNET` permission.

No exact-alarm permission (`SCHEDULE_EXACT_ALARM` / `USE_EXACT_ALARM`): reminders are inexact, so no Alarms & reminders declaration is needed.
