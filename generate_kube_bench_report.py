import json

# Load kube-bench report JSON
try:
    with open('kube-bench-report.json', 'r') as f:
        data = json.load(f)
except FileNotFoundError:
    print("kube-bench-report.json not found.")
    exit(1)
except json.JSONDecodeError as e:
    print(f"Error decoding JSON: {e}")
    exit(1)

# HTML report structure
html = """
<!DOCTYPE html>
<html>
<head>
    <title>Kube-Bench Report</title>
    <style>
        table {
            border-collapse: collapse;
            width: 100%;
        }
        th, td {
            border: 1px solid black;
            padding: 8px;
            text-align: left;
        }
        th {
            background-color: #f2f2f2;
        }
        .fail {
            background-color: #ffcccc;
        }
        .warn {
            background-color: #fff0b3;
        }
        .pass {
            background-color: #ccffcc;
        }
    </style>
</head>
<body>
    <h1>Kube-Bench Report</h1>
    <table>
        <thead>
            <tr>
                <th>Control ID</th>
                <th>Test ID</th>
                <th>Description</th>
                <th>Remediation</th>
                <th>Result</th>
            </tr>
        </thead>
        <tbody>
"""

# Parse tests and results from the JSON structure
for control in data.get("Controls", []):
    control_id = control.get("id", "N/A")
    for test in control.get("tests", []):
        for result in test.get("results", []):
            test_id = result.get("test_number", "N/A")
            description = result.get("test_desc", "N/A")
            remediation = result.get("remediation", "N/A")
            status = result.get("status", "UNKNOWN")
            row_class = "fail" if status == "FAIL" else "warn" if status == "WARN" else "pass"

            # Add a table row for each result
            html += f"""
            <tr class="{row_class}">
                <td>{control_id}</td>
                <td>{test_id}</td>
                <td>{description}</td>
                <td>{remediation}</td>
                <td>{status}</td>
            </tr>
            """

# Close the HTML structure
html += """
        </tbody>
    </table>
</body>
</html>
"""

# Save the HTML report
output_file = 'kube-bench-report.html'
with open(output_file, 'w') as f:
    f.write(html)

print(f"HTML report successfully generated: {output_file}")

