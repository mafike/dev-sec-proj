import json

# Load the combined JSON report
with open('combined-bench-report.json', 'r') as f:
    data = [json.loads(line) for line in f]

# Start HTML report structure
html = """
<!DOCTYPE html>
<html>
<head>
    <title>Combined Kube-Bench Report</title>
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
        .pass {
            background-color: #ccffcc;
        }
    </style>
</head>
<body>
    <h1>Combined Kube-Bench Report</h1>
"""

# Add a table for each target
for report in data:
    target = report.get("target", "unknown")
    html += f"<h2>Target: {target}</h2><table><tr><th>ID</th><th>Description</th><th>Remediation</th><th>Result</th></tr>"
    
    for test in report.get("Tests", []):
        for item in test.get("results", []):
            result_class = "fail" if item["status"] == "FAIL" else "pass"
            html += f"""
            <tr class="{result_class}">
                <td>{item['test_number']}</td>
                <td>{item['test_desc']}</td>
                <td>{item.get('remediation', 'N/A')}</td>
                <td>{item['status']}</td>
            </tr>
            """
    
    html += "</table>"

# Close HTML structure
html += """
</body>
</html>
"""

# Save the HTML report
with open('combined-kube-bench-report.html', 'w') as f:
    f.write(html)
print("HTML report generated: combined-kube-bench-report.html")

