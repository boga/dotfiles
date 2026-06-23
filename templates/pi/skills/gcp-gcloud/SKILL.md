---
name: gcp-gcloud
description: Work with Google Cloud Platform via the gcloud CLI. Use this skill for Compute Engine (VMs), Cloud Storage (GCS), Kubernetes Engine (GKE), Cloud Run, Cloud Functions, IAM, networking, Cloud SQL, Pub/Sub, logging, secrets, Artifact Registry, Firestore (queries, collections, documents, indexes), and project management. Also use this skill when working with any Firebase or GCP data store via the gcloud CLI.
---

# Google Cloud CLI (`gcloud`)

## Authentication & Configuration

```bash
# Login interactively
gcloud auth login

# Application Default Credentials (for client libraries)
gcloud auth application-default login

# Service account authentication
gcloud auth activate-service-account --key-file=key.json

# List authenticated accounts
gcloud auth list

# Revoke credentials
gcloud auth revoke [ACCOUNT]
```

### Project & Config

```bash
# Set active project
gcloud config set project PROJECT_ID

# Set default region/zone
gcloud config set compute/region us-central1
gcloud config set compute/zone us-central1-a

# View current config
gcloud config list

# Named configurations (switch between projects/accounts)
gcloud config configurations create my-config
gcloud config configurations activate my-config
gcloud config configurations list
```

### Info & Discovery

```bash
# Current project/account/region
gcloud config get-value project
gcloud config get-value account
gcloud config get-value compute/region

# Available services
gcloud services list --enabled
gcloud services list --available --filter="name:compute"
gcloud services enable compute.googleapis.com
```

## Projects & Billing

```bash
# List projects
gcloud projects list

# Describe a project
gcloud projects describe PROJECT_ID

# Create project
gcloud projects create PROJECT_ID --name="My Project"

# Set IAM policy on project
gcloud projects add-iam-policy-binding PROJECT_ID \
  --member="user:alice@example.com" --role="roles/editor"

# Billing accounts
gcloud billing accounts list
gcloud billing projects describe PROJECT_ID
gcloud billing projects link PROJECT_ID --billing-account=ACCOUNT_ID
```

## Compute Engine

### Instances

```bash
# List instances
gcloud compute instances list
gcloud compute instances list --filter="zone:us-central1-a"

# Create VM
gcloud compute instances create my-vm \
  --zone=us-central1-a \
  --machine-type=e2-medium \
  --image-family=debian-12 \
  --image-project=debian-cloud \
  --boot-disk-size=50GB

# Create with custom service account
gcloud compute instances create my-vm \
  --service-account=SA@PROJECT.iam.gserviceaccount.com \
  --scopes=cloud-platform

# Describe / delete / start / stop / reset
gcloud compute instances describe my-vm --zone=us-central1-a
gcloud compute instances delete my-vm --zone=us-central1-a
gcloud compute instances start my-vm --zone=us-central1-a
gcloud compute instances stop my-vm --zone=us-central1-a
gcloud compute instances reset my-vm --zone=us-central1-a

# SSH
gcloud compute ssh my-vm --zone=us-central1-a
gcloud compute ssh my-vm --zone=us-central1-a --command="uptime"

# SCP files
gcloud compute scp local-file.txt my-vm:~/remote-file.txt --zone=us-central1-a
gcloud compute scp my-vm:~/remote-file.txt ./local-file.txt --zone=us-central1-a

# Serial console output
gcloud compute instances get-serial-port-output my-vm --zone=us-central1-a

# Resize machine type (VM must be stopped)
gcloud compute instances set-machine-type my-vm \
  --machine-type=e2-standard-4 --zone=us-central1-a

# Add/remove metadata
gcloud compute instances add-metadata my-vm \
  --metadata=key=value --zone=us-central1-a

# Add/remove tags
gcloud compute instances add-tags my-vm --tags=http-server --zone=us-central1-a
```

### Disks & Images

```bash
# List disks
gcloud compute disks list

# Create disk
gcloud compute disks create my-disk --size=100GB --zone=us-central1-a

# Snapshots
gcloud compute disks snapshot my-disk --snapshot-names=my-snapshot --zone=us-central1-a
gcloud compute snapshots list
gcloud compute snapshots delete my-snapshot

# Images
gcloud compute images list
gcloud compute images list --filter="family:debian"
gcloud compute images create my-image --source-disk=my-disk --source-disk-zone=us-central1-a
```

### Instance Groups & Templates

```bash
# Instance templates
gcloud compute instance-templates list
gcloud compute instance-templates create my-template \
  --machine-type=e2-medium \
  --image-family=debian-12 --image-project=debian-cloud

# Managed instance groups
gcloud compute instance-groups managed create my-group \
  --template=my-template --size=3 --zone=us-central1-a
gcloud compute instance-groups managed resize my-group --size=5 --zone=us-central1-a
gcloud compute instance-groups managed rolling-action restart my-group --zone=us-central1-a
```

## Cloud Storage (GCS)

```bash
# List buckets
gcloud storage ls

# Create bucket
gcloud storage buckets create gs://my-bucket --location=us-central1

# Upload / download / copy
gcloud storage cp local-file.txt gs://my-bucket/
gcloud storage cp gs://my-bucket/file.txt ./local-file.txt
gcloud storage cp gs://bucket-a/file.txt gs://bucket-b/

# Recursive operations
gcloud storage cp -r ./local-dir gs://my-bucket/prefix/
gcloud storage cp -r gs://my-bucket/prefix/ ./local-dir/

# List objects
gcloud storage ls gs://my-bucket/
gcloud storage ls gs://my-bucket/** --recursive

# Remove objects
gcloud storage rm gs://my-bucket/file.txt
gcloud storage rm -r gs://my-bucket/prefix/

# Delete bucket (must be empty or use --recursive)
gcloud storage buckets delete gs://my-bucket

# Bucket details
gcloud storage buckets describe gs://my-bucket

# Set bucket IAM
gcloud storage buckets add-iam-policy-binding gs://my-bucket \
  --member="user:alice@example.com" --role="roles/storage.objectViewer"

# Signed URLs (requires service account)
gcloud storage sign-url gs://my-bucket/file.txt --duration=1h

# Sync (like rsync)
gcloud storage rsync ./local-dir gs://my-bucket/prefix/ --recursive
gcloud storage rsync gs://my-bucket/prefix/ ./local-dir --recursive --delete-unmatched-destination-objects
```

## Kubernetes Engine (GKE)

```bash
# List clusters
gcloud container clusters list

# Create cluster
gcloud container clusters create my-cluster \
  --zone=us-central1-a \
  --num-nodes=3 \
  --machine-type=e2-standard-4

# Autopilot cluster
gcloud container clusters create-auto my-cluster --region=us-central1

# Get credentials (configures kubectl)
gcloud container clusters get-credentials my-cluster --zone=us-central1-a

# Describe / delete
gcloud container clusters describe my-cluster --zone=us-central1-a
gcloud container clusters delete my-cluster --zone=us-central1-a

# Resize node pool
gcloud container clusters resize my-cluster --num-nodes=5 --zone=us-central1-a

# Node pools
gcloud container node-pools list --cluster=my-cluster --zone=us-central1-a
gcloud container node-pools create pool-2 --cluster=my-cluster \
  --machine-type=e2-standard-8 --num-nodes=2 --zone=us-central1-a
gcloud container node-pools delete pool-2 --cluster=my-cluster --zone=us-central1-a

# Update cluster (enable addons, maintenance windows, etc.)
gcloud container clusters update my-cluster \
  --enable-autoscaling --min-nodes=1 --max-nodes=10 --zone=us-central1-a
```

## Cloud Run

```bash
# Deploy from source (builds via Buildpacks)
gcloud run deploy my-service --source=. --region=us-central1

# Deploy from container image
gcloud run deploy my-service \
  --image=gcr.io/PROJECT/my-image:latest \
  --region=us-central1 \
  --allow-unauthenticated

# Deploy with config
gcloud run deploy my-service \
  --image=gcr.io/PROJECT/my-image \
  --region=us-central1 \
  --memory=512Mi --cpu=1 \
  --min-instances=0 --max-instances=10 \
  --set-env-vars="KEY=value,DB_HOST=10.0.0.1" \
  --set-secrets="API_KEY=my-secret:latest" \
  --service-account=SA@PROJECT.iam.gserviceaccount.com \
  --concurrency=80 --timeout=300

# List / describe / delete
gcloud run services list --region=us-central1
gcloud run services describe my-service --region=us-central1
gcloud run services delete my-service --region=us-central1

# View logs
gcloud run services logs read my-service --region=us-central1 --limit=50

# Manage traffic (revisions)
gcloud run services update-traffic my-service \
  --to-revisions=my-service-00002=50,my-service-00001=50 --region=us-central1
gcloud run revisions list --service=my-service --region=us-central1

# Domain mapping
gcloud run domain-mappings create --service=my-service \
  --domain=my.domain.com --region=us-central1

# Jobs (run-to-completion workloads)
gcloud run jobs create my-job --image=gcr.io/PROJECT/my-image --region=us-central1
gcloud run jobs execute my-job --region=us-central1
gcloud run jobs list --region=us-central1
```

## Cloud Functions

```bash
# Deploy (2nd gen, default)
gcloud functions deploy my-function \
  --gen2 \
  --runtime=nodejs20 \
  --trigger-http \
  --allow-unauthenticated \
  --entry-point=handler \
  --source=. \
  --region=us-central1

# Deploy with Pub/Sub trigger
gcloud functions deploy my-function \
  --gen2 --runtime=python312 \
  --trigger-topic=my-topic \
  --entry-point=handler \
  --region=us-central1

# Deploy with Cloud Storage trigger
gcloud functions deploy my-function \
  --gen2 --runtime=go122 \
  --trigger-event-filters="type=google.cloud.storage.object.v1.finalized" \
  --trigger-event-filters="bucket=my-bucket" \
  --entry-point=Handler \
  --region=us-central1

# List / describe / delete / call
gcloud functions list
gcloud functions describe my-function --region=us-central1
gcloud functions delete my-function --region=us-central1
gcloud functions call my-function --data='{"key":"value"}' --region=us-central1

# View logs
gcloud functions logs read my-function --region=us-central1 --limit=50
```

## IAM

### Service Accounts

```bash
# List service accounts
gcloud iam service-accounts list

# Create
gcloud iam service-accounts create my-sa \
  --display-name="My Service Account"

# Delete
gcloud iam service-accounts delete SA@PROJECT.iam.gserviceaccount.com

# Create key (downloads JSON key file)
gcloud iam service-accounts keys create key.json \
  --iam-account=SA@PROJECT.iam.gserviceaccount.com

# List keys
gcloud iam service-accounts keys list \
  --iam-account=SA@PROJECT.iam.gserviceaccount.com

# Grant role to service account
gcloud projects add-iam-policy-binding PROJECT_ID \
  --member="serviceAccount:SA@PROJECT.iam.gserviceaccount.com" \
  --role="roles/storage.admin"

# Impersonate a service account
gcloud config set auth/impersonate_service_account SA@PROJECT.iam.gserviceaccount.com
gcloud config unset auth/impersonate_service_account   # stop impersonation
```

### Roles & Policies

```bash
# List predefined roles
gcloud iam roles list
gcloud iam roles list --filter="name:storage"

# Describe a role
gcloud iam roles describe roles/storage.admin

# Get project IAM policy
gcloud projects get-iam-policy PROJECT_ID

# Add/remove IAM binding
gcloud projects add-iam-policy-binding PROJECT_ID \
  --member="user:alice@example.com" --role="roles/viewer"
gcloud projects remove-iam-policy-binding PROJECT_ID \
  --member="user:alice@example.com" --role="roles/viewer"

# Custom roles
gcloud iam roles create myCustomRole --project=PROJECT_ID \
  --title="My Custom Role" \
  --permissions=compute.instances.list,compute.instances.get
```

## Networking

### VPC & Subnets

```bash
# List networks / subnets
gcloud compute networks list
gcloud compute networks subnets list

# Create VPC
gcloud compute networks create my-vpc --subnet-mode=custom

# Create subnet
gcloud compute networks subnets create my-subnet \
  --network=my-vpc --range=10.0.0.0/24 --region=us-central1

# Delete
gcloud compute networks delete my-vpc
gcloud compute networks subnets delete my-subnet --region=us-central1
```

### Firewall Rules

```bash
# List rules
gcloud compute firewall-rules list
gcloud compute firewall-rules list --filter="network:my-vpc"

# Create rule
gcloud compute firewall-rules create allow-http \
  --network=my-vpc \
  --allow=tcp:80,tcp:443 \
  --source-ranges=0.0.0.0/0 \
  --target-tags=http-server

# Create rule with service account target
gcloud compute firewall-rules create allow-internal \
  --network=my-vpc \
  --allow=tcp,udp,icmp \
  --source-ranges=10.0.0.0/8

# Delete
gcloud compute firewall-rules delete allow-http

# Describe
gcloud compute firewall-rules describe allow-http
```

### Static IPs & Forwarding

```bash
# Reserve static external IP
gcloud compute addresses create my-ip --region=us-central1
gcloud compute addresses list
gcloud compute addresses describe my-ip --region=us-central1

# Reserve global IP (for load balancers)
gcloud compute addresses create my-global-ip --global
```

## Cloud SQL

```bash
# List instances
gcloud sql instances list

# Create PostgreSQL instance
gcloud sql instances create my-db \
  --database-version=POSTGRES_16 \
  --tier=db-f1-micro \
  --region=us-central1 \
  --root-password=SECURE_PASSWORD

# Create MySQL instance
gcloud sql instances create my-db \
  --database-version=MYSQL_8_0 \
  --tier=db-f1-micro \
  --region=us-central1

# Describe / delete / restart
gcloud sql instances describe my-db
gcloud sql instances delete my-db
gcloud sql instances restart my-db

# Connect via Cloud SQL Auth Proxy
gcloud sql connect my-db --user=postgres

# Databases
gcloud sql databases list --instance=my-db
gcloud sql databases create mydb --instance=my-db
gcloud sql databases delete mydb --instance=my-db

# Users
gcloud sql users list --instance=my-db
gcloud sql users create myuser --instance=my-db --password=SECURE_PASSWORD
gcloud sql users set-password myuser --instance=my-db --password=NEW_PASSWORD

# Import / export
gcloud sql import sql my-db gs://my-bucket/dump.sql --database=mydb
gcloud sql export sql my-db gs://my-bucket/dump.sql --database=mydb

# Backups
gcloud sql backups list --instance=my-db
gcloud sql backups create --instance=my-db
gcloud sql backups restore BACKUP_ID --restore-instance=my-db
```

## Pub/Sub

```bash
# Topics
gcloud pubsub topics list
gcloud pubsub topics create my-topic
gcloud pubsub topics delete my-topic
gcloud pubsub topics describe my-topic

# Publish a message
gcloud pubsub topics publish my-topic --message="Hello World"
gcloud pubsub topics publish my-topic --message='{"key":"value"}' \
  --attribute=type=json

# Subscriptions
gcloud pubsub subscriptions list
gcloud pubsub subscriptions create my-sub --topic=my-topic
gcloud pubsub subscriptions create my-sub --topic=my-topic \
  --ack-deadline=60 --message-retention-duration=7d
gcloud pubsub subscriptions delete my-sub
gcloud pubsub subscriptions describe my-sub

# Pull messages
gcloud pubsub subscriptions pull my-sub --auto-ack --limit=10

# Push subscription
gcloud pubsub subscriptions create my-push-sub --topic=my-topic \
  --push-endpoint=https://my-service.run.app/push

# Dead-letter topic
gcloud pubsub subscriptions update my-sub \
  --dead-letter-topic=my-dead-letter-topic --max-delivery-attempts=5
```

## Logging & Monitoring

### Cloud Logging

```bash
# Read logs (most recent)
gcloud logging read --limit=20

# Filter by resource
gcloud logging read 'resource.type="cloud_run_revision"' --limit=50
gcloud logging read 'resource.type="gce_instance"' --limit=50

# Filter by severity
gcloud logging read 'severity>=ERROR' --limit=50

# Filter by time range
gcloud logging read 'timestamp>="2024-01-01T00:00:00Z"' --limit=100

# Combine filters
gcloud logging read 'resource.type="cloud_run_revision" AND severity>=WARNING AND textPayload:"timeout"' --limit=50

# JSON format for programmatic consumption
gcloud logging read 'severity>=ERROR' --format=json --limit=20

# Log sinks (export logs)
gcloud logging sinks list
gcloud logging sinks create my-sink \
  storage.googleapis.com/my-log-bucket \
  --log-filter='severity>=ERROR'
```

### Cloud Monitoring

```bash
# Alerting policies
gcloud alpha monitoring policies list
gcloud alpha monitoring policies describe POLICY_ID

# Notification channels
gcloud alpha monitoring channels list

# Uptime checks
gcloud monitoring uptime list-configs
```

## Secret Manager

```bash
# Create a secret
gcloud secrets create my-secret --replication-policy="automatic"

# Add a secret version
echo -n "my-secret-value" | gcloud secrets versions add my-secret --data-file=-

# Access the latest version
gcloud secrets versions access latest --secret=my-secret

# Access a specific version
gcloud secrets versions access 2 --secret=my-secret

# List secrets / versions
gcloud secrets list
gcloud secrets versions list my-secret

# Describe / delete
gcloud secrets describe my-secret
gcloud secrets delete my-secret

# Disable / enable a version
gcloud secrets versions disable 1 --secret=my-secret
gcloud secrets versions enable 1 --secret=my-secret

# Grant access to a service account
gcloud secrets add-iam-policy-binding my-secret \
  --member="serviceAccount:SA@PROJECT.iam.gserviceaccount.com" \
  --role="roles/secretmanager.secretAccessor"
```

## Artifact Registry

```bash
# List repositories
gcloud artifacts repositories list

# Create Docker repository
gcloud artifacts repositories create my-repo \
  --repository-format=docker \
  --location=us-central1 \
  --description="Docker images"

# Configure Docker authentication
gcloud auth configure-docker us-central1-docker.pkg.dev

# List images / tags
gcloud artifacts docker images list us-central1-docker.pkg.dev/PROJECT/my-repo
gcloud artifacts docker tags list us-central1-docker.pkg.dev/PROJECT/my-repo/my-image

# Delete an image
gcloud artifacts docker images delete \
  us-central1-docker.pkg.dev/PROJECT/my-repo/my-image:tag

# Clean up untagged images
gcloud artifacts docker images list us-central1-docker.pkg.dev/PROJECT/my-repo \
  --include-tags --filter="NOT tags:*" --format="get(version)" | \
  xargs -I{} gcloud artifacts docker images delete {} --quiet
```

## Cloud Build

```bash
# Submit a build
gcloud builds submit --tag=gcr.io/PROJECT/my-image

# Submit with cloudbuild.yaml
gcloud builds submit --config=cloudbuild.yaml

# List builds
gcloud builds list --limit=10

# View build log
gcloud builds log BUILD_ID

# Triggers
gcloud builds triggers list
gcloud builds triggers describe TRIGGER_ID
gcloud builds triggers run TRIGGER_ID --branch=main
```

## App Engine

```bash
# Deploy
gcloud app deploy

# List services / versions
gcloud app services list
gcloud app versions list --service=default

# View logs
gcloud app logs read --limit=50

# Browse the app
gcloud app browse

# Traffic splitting
gcloud app services set-traffic default \
  --splits=v1=0.5,v2=0.5

# Stop a version
gcloud app versions stop VERSION --service=default
```

## Formatting & Filtering

All `gcloud` list/describe commands support `--format` and `--filter`:

```bash
# Table (default), JSON, YAML, CSV, value
gcloud compute instances list --format="table(name,zone,status)"
gcloud compute instances list --format=json
gcloud compute instances list --format="value(name)"

# Filter by field
gcloud compute instances list --filter="status=RUNNING"
gcloud compute instances list --filter="zone:us-central1"
gcloud compute instances list --filter="name~'^web-'"

# Combine format and filter
gcloud run services list --format="table(metadata.name,status.url)" --region=us-central1

# Sort
gcloud compute instances list --sort-by=~creationTimestamp  # ~ = descending

# Limit
gcloud compute instances list --limit=5

# Flatten nested fields
gcloud projects get-iam-policy PROJECT_ID \
  --flatten="bindings[].members" \
  --format="table(bindings.role,bindings.members)"

# Projection (select fields)
gcloud compute instances list \
  --format="table[box](name,zone.basename(),machineType.basename(),status)"
```

## Firestore

> **Always prefer `gcloud` CLI and `curl` with ADC over firebase-admin JS scripts for Firestore operations.**

```bash
# Enable Firestore API
gcloud services enable firestore.googleapis.com

# Create a Firestore database (native mode)
gcloud firestore databases create --location=us-central1

# List databases
gcloud firestore databases list

# Describe a database
gcloud firestore databases describe --database='(default)'

# Delete a database
gcloud firestore databases delete --database=my-db

# Export data to GCS
gcloud firestore export gs://my-bucket/firestore-backup \
  --collection-ids=users,orders

# Import data from GCS
gcloud firestore import gs://my-bucket/firestore-backup/2024-01-01T00:00:00_12345 \
  --collection-ids=users,orders

# Query / read documents via REST API (Application Default Credentials)
PROJECT=$(gcloud config get-value project)
TOKEN=$(gcloud auth application-default print-access-token)

# List documents in a collection
curl -s -H "Authorization: Bearer $TOKEN" \
  "https://firestore.googleapis.com/v1/projects/$PROJECT/databases/(default)/documents/COLLECTION"

# Get a single document
curl -s -H "Authorization: Bearer $TOKEN" \
  "https://firestore.googleapis.com/v1/projects/$PROJECT/databases/(default)/documents/COLLECTION/DOC_ID"

# Run a structured query (POST)
curl -s -X POST \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "structuredQuery": {
      "from": [{"collectionId": "users"}],
      "where": {
        "fieldFilter": {
          "field": {"fieldPath": "status"},
          "op": "EQUAL",
          "value": {"stringValue": "active"}
        }
      },
      "limit": 10
    }
  }' \
  "https://firestore.googleapis.com/v1/projects/$PROJECT/databases/(default)/documents:runQuery"

# Create / upsert a document (PATCH)
curl -s -X PATCH \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"fields": {"name": {"stringValue": "Alice"}, "age": {"integerValue": "30"}}}' \
  "https://firestore.googleapis.com/v1/projects/$PROJECT/databases/(default)/documents/COLLECTION/DOC_ID?updateMask.fieldPaths=name&updateMask.fieldPaths=age"

# Delete a document
curl -s -X DELETE \
  -H "Authorization: Bearer $TOKEN" \
  "https://firestore.googleapis.com/v1/projects/$PROJECT/databases/(default)/documents/COLLECTION/DOC_ID"

# Indexes
gcloud firestore indexes composite list
gcloud firestore indexes composite create \
  --collection-group=orders \
  --field-config=field-path=userId,order=ascending \
  --field-config=field-path=createdAt,order=descending
gcloud firestore indexes composite delete INDEX_ID

gcloud firestore indexes fields list
```

## Tips

- Use `--project=PROJECT_ID` on any command to target a different project without switching config.
- Use `--quiet` / `-q` to suppress confirmation prompts (useful in scripts).
- Use `--format=json` for programmatic consumption; pipe to `jq` for filtering.
- `gcloud components list` shows installed components; `gcloud components install COMPONENT` adds one.
- `gcloud info` shows full environment info (account, project, SDK version, paths).
- `gcloud beta` and `gcloud alpha` expose preview features not yet in GA.
- When using `--filter`, string values are case-insensitive by default; use `:` for substring match, `=` for exact match, `~` for regex.
- Combine `--format="value(FIELD)"` with shell pipelines for scripting: `gcloud compute instances list --format="value(name)" | xargs -I{} gcloud compute instances stop {}`.
