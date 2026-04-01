import os
import shutil
import subprocess
from pathlib import Path

def setup_mock_repo(base_path):
	"""
	Sets up a mock Maven repository with multiple versions of artifacts.
	"""
	mock_repo = Path(base_path) / "mock_m2"
	if mock_repo.exists():
		shutil.rmtree(mock_repo)
	mock_repo.mkdir(parents=True)
	
	# Artifact 1: Simple versions
	# com.example:app:1.0.0, 1.1.0, 1.2.0
	a1 = mock_repo / "com/example/app"
	for v in ["1.0.0", "1.1.0", "1.2.0"]:
		v_dir = a1 / v
		v_dir.mkdir(parents=True)
		(v_dir / f"app-{v}.pom").write_text("dummy")
		
	# Artifact 2: SNAPSHOT and RELEASE
	# org.test:lib:2.0.0-SNAPSHOT, 2.0.0
	a2 = mock_repo / "org/test/lib"
	for v in ["2.0.0-SNAPSHOT", "2.0.0"]:
		v_dir = a2 / v
		v_dir.mkdir(parents=True)
		(v_dir / f"lib-{v}.pom").write_text("dummy")
		
	# Artifact 3: Complex qualifiers
	# io.util:tool:1.0-alpha, 1.0-beta, 1.0
	a3 = mock_repo / "io/util/tool"
	for v in ["1.0-alpha", "1.0-beta", "1.0"]:
		v_dir = a3 / v
		v_dir.mkdir(parents=True)
		(v_dir / f"tool-{v}.pom").write_text("dummy")
		
	# Artifact 4: Only one version (should keep it)
	a4 = mock_repo / "single/art"
	v_dir = a4 / "1.0"
	v_dir.mkdir(parents=True)
	(v_dir / "art-1.0.pom").write_text("dummy")
	
	return mock_repo

def test_cleanup():
	mock_repo = setup_mock_repo(".")
	print(f"Mock repo created at {mock_repo}")
	
	# Run in dry-run mode
	print("\n--- Running Dry Run ---")
	subprocess.run(["python3", "clean_maven_cache.py", "--path", str(mock_repo)], check=True)
	
	# Verify that files are still there
	assert (mock_repo / "com/example/app/1.0.0").exists()
	
	# Run in actual mode (using 'yes' to skip the prompt or just provide input)
	print("\n--- Running Actual Deletion ---")
	process = subprocess.Popen(["python3", "clean_maven_cache.py", "--path", str(mock_repo), "--confirm"], 
							 stdin=subprocess.PIPE, text=True)
	process.communicate(input="y\n")
	
	# Verify results
	# App: should only have 1.2.0
	assert not (mock_repo / "com/example/app/1.0.0").exists()
	assert not (mock_repo / "com/example/app/1.1.0").exists()
	assert (mock_repo / "com/example/app/1.2.0").exists()
	
	# Lib: should only have 2.0.0 (2.0.0 > 2.0.0-SNAPSHOT)
	assert not (mock_repo / "org/test/lib/2.0.0-SNAPSHOT").exists()
	assert (mock_repo / "org/test/lib/2.0.0").exists()
	
	# Tool: should only have 1.0 (1.0 > 1.0-alpha, 1.0-beta)
	assert not (mock_repo / "io/util/tool/1.0-alpha").exists()
	assert not (mock_repo / "io/util/tool/1.0-beta").exists()
	assert (mock_repo / "io/util/tool/1.0").exists()
	
	# Single art: should still be there
	assert (mock_repo / "single/art/1.0").exists()
	
	print("\nTests PASSED!")
	
	# Cleanup
	shutil.rmtree(mock_repo)

if __name__ == "__main__":
	test_cleanup()
