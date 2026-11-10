# week10-storage.md
# Week 10 – HarborTech Storage Operations and Recommendations

## 1. Ticket Summary

**Ticket:** HarborTech – Storage Operations and Recovery Planning  
**Assignment:** IT4560 Week 10  
**Environment:** AWS Learner Lab / CloudShell  
**Region:** us-east-1

HarborTech needs recommendations for selecting appropriate storage services, protecting important data, managing backups, and meeting retention requirements. The client requires a recovery point no older than 24 hours and seven-year retention for certain records.

The purpose of this investigation was to examine AWS storage resources, test EBS and S3 operations, inspect backup and lifecycle settings, and recommend storage solutions based on the client's requirements.

No production changes were authorized or performed.

## 2. AWS Environment Verification

I started by verifying my AWS identity, CLI version, and default Region.

Commands used:

```bash
aws sts get-caller-identity
aws --version
aws configure get region
aws configure list
echo "$AWS_DEFAULT_REGION"
```

**Observed results:**

- AWS authentication was successful.
- AWS CLI version: 2.39.4.
- Operating environment: Amazon Linux 2023.
- Default Region: us-east-1.
- Credentials were provided through the CloudShell container role.
- No credentials or secret access keys were included in this documentation.

These checks confirmed that CloudShell was connected to the intended AWS environment.

## 3. EBS Volume Investigation

I used the EC2 commands to inspect available EBS volumes and Availability Zones.

Commands used:

```bash
aws ec2 describe-volumes --region us-east-1
```

```bash
aws ec2 describe-availability-zones --region us-east-1
```

**Observed findings:**

- An existing 8 GiB gp3 volume was attached to an EC2 instance.
- Its state was in-use.
- A separate 1 GiB gp3 practice volume was created.
- The practice volume was located in us-east-1a.
- The available Availability Zones included us-east-1a, us-east-1b, and us-east-1c.

Practice volume ID:

`vol-0c8be36819b5c5cd4`

The existing 8 GiB volume was not selected for deletion because it was attached to an EC2 instance.

### EBS Snapshot Creation

I created a snapshot of my disposable practice volume.

Command used:

```bash
aws ec2 create-snapshot \
--volume-id vol-0c8be36819b5c5cd4 \
--description "IT4560 Week10 practice" \
--tag-specifications "ResourceType=snapshot,Tags=[{Key=Purpose,Value=IT4560Week10}]" \
--region us-east-1
```

**Observed results:**

- Snapshot ID: snap-0379ade983c14592e
- Volume ID: vol-0c8be36819b5c5cd4
- Volume size: 1 GiB
- Description: IT4560 Week10 practice
- Initial snapshot state: pending

The snapshot was successfully initiated, but the supplied evidence did not confirm that it reached the completed state.

A completed snapshot alone would not prove that HarborTech meets its 24-hour recovery-point requirement. The backup schedule, latest successful recovery point, and restoration process must also be verified.

## 4. S3 Bucket Creation and Object Upload

I created a disposable S3 bucket to practice object storage operations.

Bucket name:

`it4560-week10-practice-aakiyah-2026`

Region: us-east-1

Command used:

```bash
aws s3api create-bucket \
--bucket it4560-week10-practice-aakiyah-2026 \
--region us-east-1
```

I created a local sample file:

```bash
printf "IT4560 Week10 practice\n" > week10-sample.txt
```

I verified its contents:

```bash
cat week10-sample.txt
```

I uploaded the file:

```bash
aws s3 cp week10-sample.txt \
s3://it4560-week10-practice-aakiyah-2026/week10-sample.txt \
--region us-east-1
```

The upload completed successfully.

### S3 Object Verification

I inspected the uploaded object using:

```bash
aws s3api head-object \
--bucket it4560-week10-practice-aakiyah-2026 \
--key week10-sample.txt \
--region us-east-1
```

**Observed results:**

- Object key: week10-sample.txt
- Content length: 23 bytes
- Content type: text/plain
- Server-side encryption: AES256
- Object metadata was successfully returned.
- The upload and object inspection were successful.

This confirmed that the sample file was stored in the correct bucket and that its metadata could be inspected.

## 5. S3 Versioning and Lifecycle Management

I investigated S3 versioning and lifecycle management to understand how objects can be protected and how retention policies work.

Versioning inspection command:

```bash
aws s3api get-bucket-versioning \
--bucket it4560-week10-practice-aakiyah-2026 \
--region us-east-1
```

If permitted, versioning can be enabled with:

```bash
aws s3api put-bucket-versioning \
--bucket it4560-week10-practice-aakiyah-2026 \
--versioning-configuration Status=Enabled \
--region us-east-1
```

The versioning status must be rechecked after any approved change.

### Proposed Lifecycle Configuration

I prepared a proposed lifecycle JSON rule for a practice prefix.

Filename: `week10-lifecycle-proposal.json`

```json
{
  "Rules": [
    {
      "ID": "Week10-Practice-Lifecycle",
      "Status": "Enabled",
      "Filter": {
        "Prefix": "week10-practice/"
      },
      "Expiration": {
        "Days": 30
      }
    }
  ]
}
```

I planned to validate the JSON syntax locally using:

```bash
python3 -m json.tool week10-lifecycle-proposal.json
```

The proposed rule was for practice purposes only. It was not authorized for production application.

An existing lifecycle configuration can be inspected using:

```bash
aws s3api get-bucket-lifecycle-configuration \
--bucket it4560-week10-practice-aakiyah-2026 \
--region us-east-1
```

An absent lifecycle configuration is a valid finding.

The seven-year retention requirement must be confirmed before expiration rules are implemented. Applying an expiration rule too early could permanently remove important records and create compliance problems.

## 6. Storage Recommendations and Recovery Planning

Based on the investigation, I recommend different AWS storage services depending on how the client needs to access and protect its information.

| Storage category | Recommended service | Reason |
|---|---|---|
| Application disk | Amazon EBS gp3 | Provides block storage for EC2 operating systems and applications. |
| Shared Linux working files | Amazon EFS | Allows multiple Linux instances to access shared files. |
| Uploaded documents | Amazon S3 Standard | Provides scalable object storage for frequently accessed files. |
| Seven-year records | Amazon S3 Glacier Deep Archive | Provides lower-cost storage for records accessed infrequently. |

### Recovery-Point Requirement

HarborTech requires a recovery point no older than 24 hours.

I recommend scheduling automated backups at least once every 24 hours, monitoring backup completion, and investigating failed backup jobs.

Administrators should also perform periodic restoration tests to verify that backups are usable.

For EBS, snapshots can support volume recovery. For S3, versioning and appropriate backup policies can help protect objects from accidental changes or deletion.

### Retention and Cost

Storage selection should consider performance, access frequency, recovery needs, and cost.

EBS gp3 is appropriate for application storage, while EFS supports shared Linux file access. S3 Standard is suitable for frequently accessed documents. Glacier Deep Archive is appropriate for records that must be retained for seven years but rarely accessed.

HarborTech must confirm the client's retention requirements and retrieval expectations before applying lifecycle or expiration policies.

## 7. Cleanup, Escalation, and Lessons Learned

### Cleanup

Only disposable resources created for this practice exercise should be removed.

Identified practice resources:

- S3 bucket: it4560-week10-practice-aakiyah-2026
- EBS volume: vol-0c8be36819b5c5cd4
- EBS snapshot: snap-0379ade983c14592e

The existing 8 GiB EBS volume attached to an EC2 instance was not a practice resource and must not be deleted.

S3 cleanup requires checking versioning and inspecting object versions and delete markers before deleting the bucket.

EBS cleanup commands:

```bash
aws ec2 delete-snapshot \
--snapshot-id snap-0379ade983c14592e \
--region us-east-1
```

```bash
aws ec2 delete-volume \
--volume-id vol-0c8be36819b5c5cd4 \
--region us-east-1
```

Deletion must only be attempted after confirming ownership, saving evidence, and verifying that the volume is unattached.

Cleanup completion must be documented using actual deletion results and follow-up inspection. Resources that cannot be deleted should be reported with their actual errors.

### Escalation Notes

Any production storage changes require approval from the client or authorized administrator.

Issues involving restricted AWS permissions, backup failures, retention requirements, or uncertain resource ownership should be escalated rather than bypassing security controls.

No production changes were authorized or performed during this investigation.

### Lessons Learned

This lab helped me understand the differences between block storage, file storage, and object storage.

I learned that EBS supports EC2 application storage, EFS provides shared file access, and S3 stores files as objects inside buckets.

I also learned that creating a snapshot does not automatically prove that a recovery requirement has been met. Administrators must verify backup schedules, successful completion, and restoration procedures.

Another important lesson was that lifecycle expiration rules must be reviewed carefully before implementation. Incorrect retention settings could result in permanent data loss or compliance violations.

Overall, this exercise demonstrated the importance of verifying AWS resources, protecting stored information, monitoring backups, documenting findings, and obtaining approval before making production changes.

---

**Final Status:** Practice EBS and S3 operations were performed and documented. Snapshot completion, versioning configuration, lifecycle inspection, and resource cleanup must be recorded according to their actual verification results. No production changes were authorized.
