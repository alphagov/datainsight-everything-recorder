# Data Insight Everything Recorder

This repository contains a recorder for the Data Insight platform. This is a service that listens for any messages
passing through the Data Insight platform and writes them to flat files.
By default files are stored in `/var/data/datainsight/everything` and follow the pattern `messages-YYYY-MM-DD`.

# Run the recorder

```bash
bundle exec bin/recorder run
```
