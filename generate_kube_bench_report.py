import json

# Load the JSON report
try:
    with open('kube-bench-report.json', 'r') as f:
        data = json.load(f)
except json.JSONDecodeError as e:
    print(f"Error parsing JSON: {e}")
    exit(1)

# Start HTML structure
html = """
<!DOCTYPE html>
<html>
<head>
    <title>Kube-Bench Report</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 20px;
        }
        h1 {
            text-align: center;
            color: #333;
        }
        table {
            width: 100%;
            border-collapse: collapse;
            margin: 20px auto;
            box-shadow: 0 0 10px rgba(0, 0, 0, 0.1);
        }
        th, td {
            padding: 12px 15px;
            text-align: left;
            border: 1px solid #ddd;
        }
        th {
            background-color: #f4f4f4;
            color: #333;
        }
        tr:nth-child(even) {
            background-color: #f9f9f9;
        }
        tr:hover {
            background-color: #f1f1f1;
        }
        .fail {
            background-color: #f8d7da;
            color: #721c24;
            font-weight: bold;
        }
        .warn {
            background-color: #fff3cd;
            color: #856404;
            font-weight: bold;
        }
        .pass {
            background-color: #d4edda;
            color: #155724;
            font-weight: bold;
        }
        .center {
            text-align: center;
        }
        @media screen and (max-width: 768px) {
            table {
                font-size: 14px;
            }
            th, td {
                padding: 10px;
            }
        }
    </style>
</head>
<body>
    <h1>Kube-Bench Report</h1>
    <table>
        <thead>
            <tr>
                <th class="center" style="width: 10%;">ID</th>
                <th style="width: 40%;">Description</th>
                <th style="width: 40%;">Remediation</th>
                <th class="center" style="width: 10%;">Result</th>
            </tr>
        </thead>
        <tbody>
"""

# Process the JSON and populate the HTML table
for control in data.get("Controls", []):
    for test in control.get("tests", []):
        for result in test.get("results", []):
            status = result["status"]
            result_class = "fail" if status == "FAIL" else "warn" if status == "WARN" else "pass"
            remediation = result.get('remediation', 'N/A').replace('\n', '<br>').replace('\\', '\\\\')
            html += f"""
            <tr class="{result_class}">
                <td class="center">{result.get('test_number', 'N/A')}</td>
                <td>{result.get('test_desc', 'N/A')}</td>
                <td>{remediation}</td>
                <td class="center">{status}</td>
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

print("HTML report generated: kube-bench-report.html")
