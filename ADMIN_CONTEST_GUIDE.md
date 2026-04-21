# Admin Guide: Creating and Managing Contests

This document outlines the standard operating procedure for adding new contests to the FitBuddy application using the Supabase Dashboard. 
Contribute to the `contests` table cautiously to ensure the app parses the new problems correctly.

## 1. Accessing the Database
1. Log into your [Supabase Dashboard](https://supabase.com).
2. Select the FitBuddy project.
3. On the left sidebar, click on **Table Editor**, then select the **`contests`** table.

## 2. Inserting a New Contest
Click the **"Insert row"** button. The schema requires the following mappings:

| Column | Data Type | Required? | Description & Rules |
|--------|-----------|-----------|--------------------|
| `title` | `text` | **Yes** | The user-facing name. E.g., *"Squat Champion"* |
| `description` | `text` | No | Short paragraph describing the challenge. |
| `target_reps` | `int4` | **Yes** | The exact number of reps required to autocomplete the exercise. E.g., `20` |
| `difficulty` | `text` | **Yes** | **Must** be exactly one of: `"easy"`, `"medium"`, or `"hard"`. |
| `points_reward` | `int4` | **Yes** | Number of points awarded upon successful completion. |
| `icon_system_name`| `text` | No | An SF Symbol icon string (e.g. `figure.strengthtraining.traditional`) |
| `color_hex` | `text` | No | Main accent color for the contest card (e.g. `#4CAF50`). If left blank, it defaults to the difficulty color. |
| `start_date` | `timestamptz` | No | Currently unused by the UI, but best practice to set to the launch date. |
| `end_date` | `timestamptz`| No | **CRITICAL for Badges!** Only when this date passes will medals be locked in. Set it to determine how long the contest runs. |

### ⚠️ IMPORTANT: The `exercise_name` column
To link the contest with the on-device AI Pose Detection parameters, the `exercise_name` column **MUST MATCH EXACTLY** (case-sensitive) with a model named in the Swift application. 
If there's a typo, users clicking "Start Exercise" will see a soft-fail warning saying: *"Exercise not found in library"*.

**Valid Exercise Strings:**
- `Squat`
- `Dumbbell Curl`
- `Lateral Raise`
- `Dumbbell Press`
- `Jumping Jack`
- `Push-Up`
- `Sit-Up`
- `Front Raise`
- `Kettlebell Swing`
- `High Knees`

## 3. Managing Badges
The badge system works completely **automatically** via the `user_badges` database view. 
You do not need to manually award medals. The live standings order users by:
1. `accuracy` (Highest first)
2. `time_seconds` (Lowest first)

A dynamic badge (🥇, 🥈, 🥉) is awarded to the current top 3 participants indefinitely.

## 4. Archiving or Deleting
Because of the `ON DELETE CASCADE` rule configured on the foreign keys, deleting a row from `contests` will **immediately and permanently** delete all user participant results associated with that contest. 
Avoid deleting contests unless it was a mistake. If it is an old contest, let the `end_date` pass into history.
