s = 'asdfsdf'
y = 3

r = ''
for k in range(len(s)):
  i = ord(s[k])
  i = i + y
  if (i> ord('z')):
    i = i- 26
  r = r + chr(i)

print(r)