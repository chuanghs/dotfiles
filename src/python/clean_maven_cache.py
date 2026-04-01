#!/usr/bin/env python3
import os
import shutil
import argparse
import re
from pathlib import Path
from functools import cmp_to_key

def version_to_tuple(v):
	"""
	Converts a version string into a comparable list of parts.
	Digits are converted to integers, strings remain as strings.
	"""
	parts = re.split(r'[\.\-]', v)
	result = []
	for p in parts:
		if p.isdigit():
			result.append(int(p))
		else:
			result.append(p.lower())
	return result

def compare_versions(v1, v2):
	"""
	Maven-like version comparison.
	Returns -1 if v1 < v2, 1 if v1 > v2, 0 if v1 == v2.
	"""
	t1 = version_to_tuple(v1)
	t2 = version_to_tuple(v2)
	
	# Compare common prefix
	for p1, p2 in zip(t1, t2):
		if type(p1) != type(p2):
			# Numeric parts are considered "greater" than string qualifiers
			# e.g., 1.0.1 > 1.0.SNAPSHOT
			if isinstance(p1, int):
				return 1
			else:
				return -1
		if p1 < p2:
			return -1
		if p1 > p2:
			return 1
			
	# If one version is longer than the other
	if len(t1) > len(t2):
		# If the extra part is a string qualifier, it's considered "smaller" than the base version
		# e.g., 1.0.0-SNAPSHOT < 1.0.0
		if isinstance(t1[len(t2)], str):
			return -1
		return 1
	elif len(t2) > len(t1):
		# Inverse of the above
		if isinstance(t2[len(t1)], str):
			return 1
		return -1
		
	return 0

def find_artifacts(repo_path):
	"""
	Walks the repository and groups version directories by artifact.
	"""
	artifacts = {} # artifact_path -> list of version_names
	
	for root, dirs, files in os.walk(repo_path):
		# A version directory is identified by containing a .pom file
		if any(f.endswith('.pom') for f in files):
			p = Path(root)
			artifact_dir = str(p.parent)
			version_name = p.name
			
			if artifact_dir not in artifacts:
				artifacts[artifact_dir] = []
			
			if version_name not in artifacts[artifact_dir]:
				artifacts[artifact_dir].append(version_name)
			
	return artifacts

def clean_cache(repo_path, dry_run=True):
	"""
	Identifies and removes old versions of artifacts.
	"""
	print(f"Scanning repository: {repo_path}")
	artifacts = find_artifacts(repo_path)
	to_delete = []
	
	# Use cmp_to_key for the custom comparison function
	version_key = cmp_to_key(compare_versions)
	
	for artifact_dir, versions in sorted(artifacts.items()):
		if len(versions) <= 1:
			continue
			
		# Sort versions and identify the latest one
		sorted_versions = sorted(versions, key=version_key)
		latest_version = sorted_versions[-1]
		old_versions = sorted_versions[:-1]
		
		print(f"\nArtifact: {os.path.relpath(artifact_dir, repo_path)}")
		print(f"  [KEEP]   {latest_version}")
		for v in old_versions:
			path = os.path.join(artifact_dir, v)
			to_delete.append(path)
			print(f"  [DELETE] {v}")
			
	if not to_delete:
		print("\nNo old versions found.")
		return

	print(f"\nSummary:")
	print(f"  Total artifacts with multiple versions: {sum(1 for v in artifacts.values() if len(v) > 1)}")
	print(f"  Total directories to delete: {len(to_delete)}")
	
	if dry_run:
		print("\n*** DRY RUN MODE: No files were deleted. ***")
		print("*** Run with --confirm to perform actual deletion. ***")
	else:
		confirm = input(f"\nAre you sure you want to delete {len(to_delete)} directories? (y/N): ")
		if confirm.lower() == 'y':
			for path in to_delete:
				try:
					shutil.rmtree(path)
					print(f"Deleted: {path}")
				except Exception as e:
					print(f"Error deleting {path}: {e}")
			print("\nCleanup complete.")
		else:
			print("\nCleanup cancelled.")

if __name__ == "__main__":
	parser = argparse.ArgumentParser(description="Clean up old artifact versions in local Maven repository.")
	parser.add_argument("--path", default=os.path.expanduser("~/.m2/repository"), help="Path to local Maven repository")
	parser.add_argument("--confirm", action="store_true", help="Skip the dry-run and proceed to deletion (will still ask for final confirmation)")
	
	args = parser.parse_args()
	
	repo_path = os.path.abspath(args.path)
	if not os.path.exists(repo_path):
		print(f"Error: Path {repo_path} does not exist.")
		exit(1)
		
	clean_cache(repo_path, dry_run=not args.confirm)
