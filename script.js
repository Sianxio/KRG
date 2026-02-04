// Korean Ramen Guide - JavaScript
// Filter functionality for shopping list page

document.addEventListener('DOMContentLoaded', function() {
    // Filter buttons
    const filterButtons = document.querySelectorAll('.filter-btn');
    const productCards = document.querySelectorAll('.product-card');
    
    if (filterButtons.length > 0) {
        filterButtons.forEach(button => {
            button.addEventListener('click', function() {
                const filter = this.getAttribute('data-filter');
                
                // Update active button
                filterButtons.forEach(btn => btn.classList.remove('active'));
                this.classList.add('active');
                
                // Filter products
                productCards.forEach(card => {
                    const category = card.getAttribute('data-category');
                    
                    if (filter === 'all' || category === filter) {
                        card.style.display = 'block';
                        // Add fade-in animation
                        card.style.animation = 'fadeIn 0.5s';
                    } else {
                        card.style.display = 'none';
                    }
                });
            });
        });
    }
    
    // Smooth scroll for anchor links
    document.querySelectorAll('a[href^="#"]').forEach(anchor => {
        anchor.addEventListener('click', function (e) {
            const href = this.getAttribute('href');
            if (href !== '#') {
                e.preventDefault();
                const target = document.querySelector(href);
                if (target) {
                    target.scrollIntoView({
                        behavior: 'smooth',
                        block: 'start'
                    });
                }
            }
        });
    });
    
    // Add click tracking for affiliate links (optional - for analytics)
    const affiliateLinks = document.querySelectorAll('.btn-affiliate');
    affiliateLinks.forEach(link => {
        link.addEventListener('click', function() {
            const productName = this.closest('.product-card').querySelector('h4').textContent;
            console.log('Affiliate click:', productName);
            // You can add Google Analytics or other tracking here
        });
    });
});

// Add CSS for fade-in animation
const style = document.createElement('style');
style.textContent = `
    @keyframes fadeIn {
        from {
            opacity: 0;
            transform: translateY(10px);
        }
        to {
            opacity: 1;
            transform: translateY(0);
        }
    }
`;
document.head.appendChild(style);
