<?php
/**
 * The main template file
 *
 * @package Pet_Paws
 */

get_header();
?>

<main id="primary" class="site-main">
    <div class="container">
        <div class="content-area">
            <?php if (have_posts()): ?>
                
                <?php if (is_home() && !is_front_page()): ?>
                <header class="page-header">
                    <h1 class="page-title"><?php single_post_title(); ?></h1>
                </header>
                <?php endif; ?>
                
                <div class="posts-grid">
                    <?php
                    while (have_posts()):
                        the_post();
                        ?>
                        <article id="post-<?php the_ID(); ?>" <?php post_class('post-card'); ?>>
                            <?php if (has_post_thumbnail()): ?>
                            <div class="post-thumbnail">
                                <a href="<?php the_permalink(); ?>">
                                    <?php the_post_thumbnail('medium_large'); ?>
                                </a>
                            </div>
                            <?php endif; ?>
                            
                            <div class="post-content">
                                <header class="entry-header">
                                    <?php
                                    if (is_singular()):
                                        the_title('<h1 class="entry-title">', '</h1>');
                                    else:
                                        the_title('<h2 class="entry-title"><a href="' . esc_url(get_permalink()) . '" rel="bookmark">', '</a></h2>');
                                    endif;
                                    ?>
                                    
                                    <?php if ('post' === get_post_type()): ?>
                                    <div class="entry-meta">
                                        <span class="posted-on">
                                            <i class="fas fa-calendar"></i>
                                            <?php echo get_the_date(); ?>
                                        </span>
                                        <span class="posted-by">
                                            <i class="fas fa-user"></i>
                                            <?php the_author(); ?>
                                        </span>
                                    </div>
                                    <?php endif; ?>
                                </header>
                                
                                <div class="entry-summary">
                                    <?php the_excerpt(); ?>
                                </div>
                                
                                <footer class="entry-footer">
                                    <a href="<?php the_permalink(); ?>" class="read-more">
                                        <?php esc_html_e('Read More', 'pet-paws'); ?>
                                        <i class="fas fa-arrow-right"></i>
                                    </a>
                                </footer>
                            </div>
                        </article>
                    <?php
                    endwhile;
                    ?>
                </div>
                
                <?php
                the_posts_navigation(array(
                    'prev_text' => __('Older posts', 'pet-paws'),
                    'next_text' => __('Newer posts', 'pet-paws'),
                ));
                ?>
                
            <?php
            else:
                ?>
                <section class="no-results not-found">
                    <header class="page-header">
                        <h1 class="page-title"><?php esc_html_e('Nothing Found', 'pet-paws'); ?></h1>
                    </header>
                    
                    <div class="page-content">
                        <?php
                        if (is_home() && current_user_can('publish_posts')):
                            ?>
                            <p>
                                <?php
                                printf(
                                    wp_kses(
                                        __('Ready to publish your first post? <a href="%1$s">Get started here</a>.', 'pet-paws'),
                                        array(
                                            'a' => array(
                                                'href' => array(),
                                            ),
                                        )
                                    ),
                                    esc_url(admin_url('post-new.php'))
                                );
                                ?>
                            </p>
                        <?php
                        elseif (is_search()):
                            ?>
                            <p><?php esc_html_e('Sorry, but nothing matched your search terms. Please try again with some different keywords.', 'pet-paws'); ?></p>
                            <?php
                            get_search_form();
                        else:
                            ?>
                            <p><?php esc_html_e('It seems we can&rsquo;t find what you&rsquo;re looking for. Perhaps searching can help.', 'pet-paws'); ?></p>
                            <?php
                            get_search_form();
                        endif;
                        ?>
                    </div>
                </section>
            <?php
            endif;
            ?>
        </div>
    </div>
</main>

<?php
get_footer();
?>