# Data Directory

This directory contains the datasets used by the Enterprise Banking Data Platform.

## Important

The data files are **not** stored in this repository.

Instead, each developer should generate their own synthetic datasets using the project's event generator/emulator.

This approach ensures that:

* Every generated dataset is unique.
* No sensitive or real customer information is included.
* The project remains lightweight without committing large data files to Git.
* Different users can test the pipeline with different data distributions and volumes.

## Generating the Data

Run the project's data generator to create the required CSV files. The generated files should be placed in this directory before loading them into Snowflake.

Because the data is generated dynamically, the exact records, IDs, timestamps, and values will differ for every user while maintaining the same schema and business rules.

## Notes

* Generated datasets are intended for development and testing only.
* If business rules or the data model change, regenerate the datasets to ensure they reflect the latest generator logic.
* The SQL pipeline expects the generated files to follow the project's predefined schema.
