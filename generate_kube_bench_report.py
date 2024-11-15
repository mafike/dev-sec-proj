import json

# Load the combined JSON report
try:
    with open('combined-bench.json', 'r') as f:
        data = json.load(f)
except json.JSONDecodeError as e:
    print(f"Error parsing JSON: {e}")
    exit(1)

# Start HTML structure
html = """
<!DOCTYPE html>
<html>
<head>
    <title>Kube-Bench Combined Report</title>
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
            background-color: #fff5cc;
        }
        .pass {
            background-color: #ccffcc;
        }
    </style>
</head>
<body>
    <h1>Kube-Bench Combined Report</h1>
"""

# Process each benchmark type
for benchmark in data.get("Benchmarks", []):
    html += f"<h2>{benchmark['type'].capitalize()} Benchmarks</h2>"
    html += """
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
    for control in benchmark.get("controls", []):
        for test in control.get("tests", []):
            for result in test.get("results", []):
                status = result["status"]
                result_class = "fail" if status == "FAIL" else "warn" if status == "WARN" else "pass"
                remediation = result.get('remediation', 'N/A').replace('\n', '<br>').replace('\\', '\\\\')
                html += f"""
                <tr class="{result_class}">
                    <td>{result.get('test_number', 'N/A')}</td>
                    <td>{result.get('test_desc', 'N/A')}</td>
                    <td>{remediation}</td>
                    <td>{status}</td>
                </tr>
                """
    html += """
        </tbody>
    </table>
    """

# Close the HTML structure
html += """
</body>
</html>
"""

# Save the HTML report
with open('kube-bench-combined-report.html', 'w') as f:
    f.write(html)

print("HTML report generated: kube-bench-combined-report.html")

