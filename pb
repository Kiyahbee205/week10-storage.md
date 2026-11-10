# HarborTech Operations Playbook: Week 10 Storage Operations

## 1. Purpose

This playbook explains how to manage AWS storage resources, protect company data, create backups, verify recovery, and control storage costs.

## 2. AWS Environment

The practice environment uses AWS CloudShell in the us-east-1 region.

Before performing storage operations, verify the AWS environment.

Commands:

- `aws sts get-caller-identity`
- `aws configure list`
- `echo "$AWS_DEFAULT_REGION"`

Never publish account IDs, passwords, access keys, or security tokens.

## 3. Application Disk Storage – Amazon EBS

Amazon EBS provides block storage for EC2 instances. It is recommended for operating systems, application files, and workloads that need persistent disk storage.

Procedures:

1. Review existing EBS volumes.
2. Check volume size, type, attachment status, and encryption.
3. Use gp3 for general application storage.
4. Create snapshots according to the approved backup schedule.
5. Verify that snapshots finish successfully.

Command: `aws ec2 describe-volumes --region us-east-1`

## 4. Shared Linux Working Files – Amazon EFS

Amazon EFS provides shared file storage that multiple Linux EC2 instances can access.

Procedures:

1. Identify applications that need shared files.
2. Confirm network connectivity and access permissions.
3. Configure EFS for approved shared workloads.
4. Monitor storage usage and backup status.
5. Test access from authorized instances.

EFS is useful when multiple servers need access to the same working files.

## 5. Uploaded Documents – Amazon S3

Amazon S3 provides scalable object storage for uploaded documents, images, and other files.

Procedures:

1. Review existing S3 buckets.
2. Confirm bucket ownership and permissions.
3. Upload approved files.
4. Verify uploads and encryption.
5. Enable versioning when approved.

Commands:

- `aws s3 ls`
- `aws s3 ls s3://YOUR-BUCKET-NAME/`
- `aws s3api head-object --bucket YOUR-BUCKET-NAME --key YOUR-FILE-NAME --region us-east-1`

## 6. Seven-Year Records and Retention

Amazon S3 Glacier Deep Archive is recommended for records that must be retained for seven years and are rarely accessed.

Before creating lifecycle rules, confirm the retention period, legal requirements, retrieval time, and who can approve deletion.

Lifecycle policies should not expire records before the required retention period ends.

Glacier Deep Archive can reduce long-term storage costs, but retrieving archived information takes longer and may involve additional charges.

## 7. Backup and Recovery Procedures

HarborTech requires a 24-hour Recovery Point Objective (RPO). This means the latest successful recovery point should be no more than 24 hours old.

Procedures:

1. Schedule automated backups at least every 24 hours.
2. Monitor backup completion.
3. Investigate failed backups.
4. Verify the latest successful recovery point.
5. Perform restore tests.
6. Document recovery results.

Command: `aws ec2 describe-snapshots --owner-ids self --region us-east-1`

A snapshot showing pending is still being created. A snapshot showing completed has finished creating. A restore test is still necessary to verify that the recovered data is usable.

## 8. Storage Recommendations

| Data Category | Recommended Storage | Purpose |
|---|---|---|
| Application disks | EBS gp3 | Persistent application storage |
| Shared Linux files | Amazon EFS | Shared access between servers |
| Uploaded documents | Amazon S3 Standard | Frequently accessed files |
| Seven-year records | S3 Glacier Deep Archive | Long-term archival storage |

Storage choices should consider performance, access frequency, recovery time, retention, and cost.

## 9. Cleanup Procedures

Temporary resources should only be deleted after confirming ownership and receiving approval.

Commands to review resources:

- `aws ec2 describe-volumes --region us-east-1`
- `aws ec2 describe-snapshots --owner-ids self --region us-east-1`
- `aws s3 ls s3://YOUR-BUCKET-NAME/ --recursive`

For versioned buckets, review object versions and delete markers before removing the bucket.

After approved cleanup, verify that resources have been removed. Document any resources that remain.

Never delete production resources or unknown resources without authorization.

## 10. Escalation and Security

Contact the appropriate AWS administrator when:

- Backup jobs fail.
- Recovery points exceed the 24-hour requirement.
- Storage permissions are denied.
- Retention requirements are unclear.
- A
