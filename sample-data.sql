INSERT INTO challenges (challenge_date, text)
VALUES
    (CURRENT_DATE - INTERVAL '2 days', 'The quick brown fox jumps over the lazy dog. This classic pangram is perfect for practicing your typing speed and accuracy.'),
    (CURRENT_DATE - INTERVAL '1 days', 'Programming is the art of telling another human what one wants the computer to do. — Donald Knuth'),
    (CURRENT_DATE, 'To be or not to be, that is the question. Whether ''tis nobler in the mind to suffer the slings and arrows of outrageous fortune...'),
    (CURRENT_DATE + INTERVAL '1 days', 'The only way to do great work is to love what you do. If you haven''t found it yet, keep looking. Don''t settle. — Steve Jobs'),
    (CURRENT_DATE + INTERVAL '2 days', 'Success is not final, failure is not fatal: It is the courage to continue that counts. — Winston Churchill');
