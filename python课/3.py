s = input('请输入明文:\n')
y = input('请输入密钥数字:\n')
y = int(y)

r = ''
for k in range(len(s)):
  i = ord(s[k])
  i = i + y
  if (i> ord('z')):
    i = i- 26
  r = r + chr(i)

print('你的密文是:' + r)
