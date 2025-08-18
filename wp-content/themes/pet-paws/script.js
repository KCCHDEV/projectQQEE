// Cart management
let cartCount = 0;

// Update cart count display
function updateCartCount() {
    document.querySelector('.cart-count').textContent = cartCount;
}

// Category dropdown functionality
document.addEventListener('DOMContentLoaded', function() {
    const categoryBtn = document.querySelector('.category-btn');
    const categoryDropdown = document.querySelector('.category-dropdown');
    
    // Toggle dropdown menu (for future implementation)
    categoryBtn.addEventListener('click', function() {
        // Placeholder for dropdown menu
        console.log('Category dropdown clicked');
    });
    
    // Search functionality
    const searchInput = document.querySelector('.search-input');
    const searchBtn = document.querySelector('.search-btn');
    const bottomSearch = document.querySelector('.bottom-search');
    
    function performSearch(query) {
        console.log('Searching for:', query);
        // Placeholder for search functionality
    }
    
    searchBtn.addEventListener('click', function() {
        performSearch(searchInput.value);
    });
    
    searchInput.addEventListener('keypress', function(e) {
        if (e.key === 'Enter') {
            performSearch(searchInput.value);
        }
    });
    
    bottomSearch.addEventListener('keypress', function(e) {
        if (e.key === 'Enter') {
            performSearch(bottomSearch.value);
        }
    });
    
    // Category items click handler
    const categoryItems = document.querySelectorAll('.category-item');
    
    categoryItems.forEach(item => {
        item.addEventListener('click', function() {
            const categoryName = this.querySelector('span').textContent;
            console.log('Category selected:', categoryName);
            // Placeholder for category navigation
        });
    });
    
    // Navigation links
    const navLinks = document.querySelectorAll('.nav-link');
    
    navLinks.forEach(link => {
        link.addEventListener('click', function(e) {
            e.preventDefault();
            
            // Remove active class from all links
            navLinks.forEach(l => l.classList.remove('active'));
            
            // Add active class to clicked link
            this.classList.add('active');
            
            // Handle navigation
            const section = this.textContent.trim();
            console.log('Navigating to:', section);
        });
    });
    
    // Smooth scroll for internal links
    document.querySelectorAll('a[href^="#"]').forEach(anchor => {
        anchor.addEventListener('click', function (e) {
            e.preventDefault();
            const target = document.querySelector(this.getAttribute('href'));
            if (target) {
                target.scrollIntoView({
                    behavior: 'smooth'
                });
            }
        });
    });
});

// Placeholder cart functions
function addToCart(productId) {
    cartCount++;
    updateCartCount();
    console.log('Product added to cart:', productId);
}

function removeFromCart(productId) {
    if (cartCount > 0) {
        cartCount--;
        updateCartCount();
    }
    console.log('Product removed from cart:', productId);
}