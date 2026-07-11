<img width="200" height="200" alt="image" src="https://github.com/user-attachments/assets/a0c2f1ad-d686-4990-8095-1a0822378aab" />


# YTV Television Scheduling Archive & Live Channel


A historical and ongoing archive of television broadcasting schedules for the Canadian cable channel **YTV**, stored in clean, machine-readable `.csv` formats. Data was scraped from the [YTV Wiki](https://ytv-schedule-archives.fandom.com/wiki/YTV_Schedule_Archives_Wiki) and will be updated periodically.

This project also includes the project files necessary to host [YTV25](https://ytvarchive.com/) which simulates a live television broadcast of the iconic Canadian youth network, synchronized exactly 25 years ago to the calendar day. 

This repository serves as a data resource for media researchers, television historians, and nostalgia enthusiasts tracking broadcasting trends, programming blocks (like *The Zone*, *The Fresh Prince of Bel-Air*, or *SpongeBob SquarePants*), and regional scheduling shifts over the years.

### Note on Timezones

YTV historically broadcast multiple feeds across Canada (primarily Eastern and Pacific). Unless explicitly flagged in a separate regional sub-folder, all times in the primary datasets are normalized to Eastern Time (ET).

### How this Works
A daily GitHub Action reads the YTV programming schedule from exactly 25 years ago and fetches the corresponding videos from YouTube. Once the video IDs are retrieved and the schedule updated, a new build is automatically triggered to deploy the updated YTV25 website.

[![Update Channel Schedule](https://github.com/imRohan/YTV-Schedule-Archives/actions/workflows/update_channel_cron.yml/badge.svg)](https://github.com/imRohan/YTV-Schedule-Archives/actions/workflows/update_channel_cron.yml)

To back this, a weekly GitHub Action fetches upcoming YTV programming schedules to keep the repository up to date. This automation allows the YTV25 channel to run indefinitely, or for 25 years after YTV ceases to air.

[![Fetch New Schedules](https://github.com/imRohan/YTV-Schedule-Archives/actions/workflows/scrape_data_cron.yml/badge.svg)](https://github.com/imRohan/YTV-Schedule-Archives/actions/workflows/scrape_data_cron.yml)

## License

This data collection is made available for educational and historical research purposes. The compiled datasets (.csv files) are distributed under the Creative Commons Attribution 4.0 International (CC BY 4.0) license. Individual program titles, logotypes, and intellectual property remain the property of Corus Entertainment and their respective production houses.
