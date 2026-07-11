import os
import re
import sys

def validate():
    print("=" * 60)
    print("🚀 NEXORA CI/CD - Version Consistency Validator")
    print("=" * 60)

    pubspec_path = "pubspec.yaml"
    gradle_path = "app/build.gradle.kts"

    errors = []
    warnings = []

    # 1. Parse pubspec.yaml
    pubspec_version = None
    if os.path.exists(pubspec_path):
        with open(pubspec_path, "r") as f:
            for line in f:
                if line.strip().startswith("version:"):
                    pubspec_version = line.split(":", 1)[1].strip()
                    break
    else:
        errors.append(f"❌ Missing pubspec.yaml at {pubspec_path}")

    # 2. Parse app/build.gradle.kts
    gradle_version_code = None
    gradle_version_name = None
    if os.path.exists(gradle_path):
        with open(gradle_path, "r") as f:
            content = f.read()
            # Match versionCode = 14
            code_match = re.search(r"versionCode\s*=\s*(\d+)", content)
            if code_match:
                gradle_version_code = code_match.group(1)
            # Match versionName = "1.4.0-RC1"
            name_match = re.search(r"versionName\s*=\s*\"([^\"]+)\"", content)
            if name_match:
                gradle_version_name = name_match.group(1)
    else:
        errors.append(f"❌ Missing app/build.gradle.kts at {gradle_path}")

    # 3. Validate pubspec version format (X.Y.Z+Build)
    pub_version_name = None
    pub_version_code = None
    if pubspec_version:
        pub_match = re.match(r"^([a-zA-Z0-9\.\-]+)\+(\d+)$", pubspec_version)
        if pub_match:
            pub_version_name = pub_match.group(1)
            pub_version_code = pub_match.group(2)
            print(f"✅ pubspec.yaml Version Found: {pubspec_version}")
            print(f"   └─ Version Name: {pub_version_name}")
            print(f"   └─ Version Code (Build): {pub_version_code}")
        else:
            errors.append(f"❌ Invalid version format in pubspec.yaml: '{pubspec_version}'. Expected 'X.Y.Z+A' or 'X.Y.Z-Suffix+A'.")
    
    # 4. Validate Gradle versions
    if gradle_version_code:
        print(f"✅ build.gradle.kts Version Code Found: {gradle_version_code}")
    else:
        errors.append("❌ Could not find 'versionCode' in app/build.gradle.kts")

    if gradle_version_name:
        print(f"✅ build.gradle.kts Version Name Found: {gradle_version_name}")
    else:
        errors.append("❌ Could not find 'versionName' in app/build.gradle.kts")

    # 5. Consistency check
    print("-" * 60)
    print("📊 Consistency Summary:")
    
    # If both are parsed, compare them
    if pub_version_name and gradle_version_name:
        if pub_version_name != gradle_version_name:
            warnings.append(
                f"⚠️ Version Name Mismatch: pubspec.yaml has '{pub_version_name}' while build.gradle.kts has '{gradle_version_name}'."
            )
    if pub_version_code and gradle_version_code:
        if pub_version_code != gradle_version_code:
            warnings.append(
                f"⚠️ Version Code Mismatch: pubspec.yaml has '{pub_version_code}' while build.gradle.kts has '{gradle_version_code}'."
            )

    if errors or warnings:
        if errors:
            print("\n".join(errors))
        if warnings:
            print("\n".join(warnings))
        print("\n💡 Tip: In mixed/hybrid projects, native and Flutter versions can sometimes be decoupled intentionally.")
        print("💡 Ensure this is intentional before shipping to production.")
        print("=" * 60)
        sys.exit(1)
    else:
        print("PASS")
        print("Version Name OK")
        print("Version Code OK")
        print("✨ Version sync validation succeeded! All files are in lockstep.")
    
    print("=" * 60)

if __name__ == "__main__":
    validate()
