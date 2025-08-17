<?php 
// Pet Paws Theme Functions 
add_action('wp_enqueue_scripts', 'pet_paws_scripts'); 
function pet_paws_scripts() { 
    wp_enqueue_style('pet-paws-style', get_stylesheet_uri()); 
    wp_enqueue_script('pet-paws-script', get_template_directory_uri() . '/script.js', array(), '1.0', true); 
} 
