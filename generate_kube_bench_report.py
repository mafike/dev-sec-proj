import json

# Load the JSON report
with open('kube-bench-report.json', 'r') as f:
    data = json.load(f)

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
            background-color: #ffffcc;
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
                <th>ID</th>
                <th>Description</th>
                <th>Remediation</th>
                <th>Result</th>
            </tr>
        </thead>
        <tbody>
"""

# Iterate over controls and generate rows for the HTML table
for control in data.get("Controls", []):
    for test in control.get("tests", []):
        for result in test.get("results", []):
            result_class = "fail" if result["status"] == "FAIL" else "warn" if result["status"] == "WARN" else "pass"
            html += f"""
            <tr class="{result_class}">
                <td>{result['test_number']}</td>
                <td>{result['test_desc']}</td>
                <td>{result.get('remediation', 'N/A')}</td>
                <td>{result['status']}</td>
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
with open('kube-bench-report.html', 'w') as f:
    f.write(html)
