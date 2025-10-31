-- SQL to maintain a denormalized comment_count on posts using triggers
-- Run this in your Supabase SQL editor or psql against the project's DB

-- 1) Add comment_count column to posts (if not already present)
ALTER TABLE IF EXISTS public.posts
  ADD COLUMN IF NOT EXISTS comment_count bigint DEFAULT 0;

-- 2) Create a function that updates comment_count on insert/delete
CREATE OR REPLACE FUNCTION public._posts_comment_count_trigger()
RETURNS trigger AS $$
BEGIN
  IF (TG_OP = 'INSERT') THEN
    UPDATE public.posts SET comment_count = COALESCE(comment_count, 0) + 1 WHERE id = NEW.post;
    RETURN NEW;
  ELSIF (TG_OP = 'DELETE') THEN
    UPDATE public.posts SET comment_count = GREATEST(COALESCE(comment_count, 0) - 1, 0) WHERE id = OLD.post;
    RETURN OLD;
  END IF;
  RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- 3) Attach trigger to post_comments table
DROP TRIGGER IF EXISTS trg_post_comments_count ON public.post_comments;
CREATE TRIGGER trg_post_comments_count
AFTER INSERT OR DELETE ON public.post_comments
FOR EACH ROW EXECUTE FUNCTION public._posts_comment_count_trigger();

-- 4) Optional: backfill counts for existing posts
-- UPDATE public.posts SET comment_count = coalesce(sub.count, 0)
-- FROM (
--   SELECT post, COUNT(*) as count FROM public.post_comments GROUP BY post
-- ) sub WHERE posts.id = sub.post;

-- Grant necessary privileges if needed
GRANT SELECT, UPDATE ON public.posts TO authenticated;
