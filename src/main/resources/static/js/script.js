// Show message when button is clicked
function showMessage() {
    alert("Let's automate, innovate, and secure the future—together!");
}

// Function to open the contact modal
function showContactModal() {
    $('#contactModal').modal('show');
}

// Smooth scrolling for internal links
document.querySelectorAll('a[href^="#"]').forEach(anchor => {
    anchor.addEventListener('click', function (e) {
        e.preventDefault();
        document.querySelector(this.getAttribute('href')).scrollIntoView({
            behavior: 'smooth'
        });
    });
});

// Form submission handling
document.addEventListener('DOMContentLoaded', function() {
    const form = document.querySelector('#contactModal form');
    form.addEventListener('submit', function (e) {
        e.preventDefault(); // Prevent the form from actually submitting

        const name = document.getElementById('name').value;
        const email = document.getElementById('email').value;

        if (name && email) {
            alert(`Thank you, ${name}! We'll be in touch via ${email}.`);
            $('#contactModal').modal('hide');
            form.reset();
        } else {
            alert('Please fill in all fields.');
        }
    });
});
