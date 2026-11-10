"""Local stand-in render of the storyboard screens (not the real canvas): expands the simple template tags and screenshots each screen."""
import os, re
from playwright.sync_api import sync_playwright

HERE = os.path.dirname(os.path.abspath(__file__))
PROJ = os.path.join(HERE, '..', 'mermaid', 'project')
OUT = os.path.join(HERE, 'out')
ART = '/home/claude/mermaid-art'
BLOBS = {'99038a81358c4be22907e496d3b3fc2b': 'bg_main.jpg', '4cda8aa9825139f9d1fc1657e0a0a7cc': 'bg_map.jpg', 'b945d0cb9fea76f20bdb1900c84a73af': 'bg_tide.jpg', 'c2f334d1c55ea2f929d229744aa6932c': 'bg_coral.jpg', 'fad06595da2f5049830b8e3eaab1ab1f': 'bg_chest.jpg', 'b8216f445ee94a39ebb80aa502f2c39e': 'bg_grotto.jpg', '4c3256eeac1e58df9ca58eae7da8cf6c': 'mermaid_a.png', '7b463550021fb0c4656fba9997661504': 'mermaid_b.png', '55979298cc260c67472b7507326cf54e': 'mermaid_c.png', 'a7197132e309854e8e4c3a4de4a1f3fa': 'crab.png', 'c514494140f64366a6c18194b200d8fa': 'shell_orange.png', 'e16f89315d20cc946f7b0d3447d4c409': 'shell_teal.png', '32d9694cd52d802b818de72f398d7e79': 'mermaid_ophelia.png', 'ca712ba0e9e4d3570f8e5be0a347f16f': 'mermaid_daphne.png', '274708def48dfbf5c69b795f8fea630a': 'mermaid_violet.png', 'f0f11dd375d1f608dcd309a3bfc0b396': 'frame_tide.jpg', '50bcbabbb34ea6af29fe423fc2635765': 'frame_tide_bg.jpg', '6d2daa22b78eadb0a28b07eb9cc1b244': 'kelp_r.png', '6fdd0f167233bc8ebb1f1d66da1d42a2': 'crab_legs.png', 'ca8bd4da8bfc7046ce8107250860f5f4': 'crab_arm_l.png', '95bc4e0f27880635ae878334cf7c63a4': 'crab_arm_r.png', '6f5238f0e6dccb5521f2fd281ca513d0': 'crab_body.png', 'fd51dc9f37a2b5d07c5b78ba6c498134': 'crab_eyes.png', '5a8029c1468ba43a09036fe075ddce4b': 'crab_eyes_shut.png', '2dbcb4439a3dbc6ea08083c1ca3df068': 'icon_shell.png', 'e3be6ff5403930dce6d33da295ed609c': 'icon_map.png', 'f5da22afd71701411ddd58a74a8d4958': 'icon_pearl.png', 'c836b8a3d2ca47a1b977004c8063afcf': 'tide_bg0.jpg', 'cf9ec3172afe0e2ba521e3d7a68581c7': 'tide_kelp_far.webp', 'bf855e5597a9899158ecbdf466277c14': 'tide_kelp_mid.webp', '738dd00160cae0c42cc227eb669db4f7': 'tide_kelp_left.webp', '1944a6de44675467ac2c36a538372c51': 'tide_kelp_right.webp', '812352a309662bd1a2b302bb8e833538': 'tide_fg.webp', '3cd10e4316fd2088c7a0c55bee6043a4': 'tide_grass.png', 'a66cf0a3bf24bea72648df9ebf4a6ed6': 'star_pink.png', '714576a905b323a8ba56cd3a8d04e661': 'star_orange.png', 'c1bf8ae55aa7aafb5ee62a17166bcddb': 'sprite_bubble.png', '589aae9bd55487189267ea516ff962e8': 'sprite_fish.png'}
ORB = 'radial-gradient(circle at 32% 28%, rgba(255,255,255,0.9) 0%, rgba(150,240,235,0.55) 26%, rgba(16,96,140,0.62) 72%)'
GOLD = 'radial-gradient(circle at 32% 28%, rgba(255,255,255,0.9) 0%, rgba(255,213,138,0.92) 28%, rgba(255,140,50,0.9) 75%)'
GLOW = '0 0 34px rgba(190,250,245,0.8), inset 0 0 26px rgba(255,255,255,0.4)'
def pearls(n): return [dict(bg='#FFF6EC' if i < n else 'rgba(255,255,255,0.1)', glow='0 0 10px rgba(255,241,210,0.9)' if i < n else 'none') for i in range(10)]
GLASS = 'radial-gradient(circle at 32% 24%, #FFFFFF 0%, #F2FFFB 22%, #CFF5EE 60%, #9FE8DE 100%)'
GOLD2 = 'radial-gradient(circle at 32% 24%, #FFF4DC 0%, #FFD27A 42%, #FF9A3D 100%)'
SH = '0 10px 22px rgba(6,26,51,0.3), inset 0 -10px 18px rgba(23,135,156,0.25)'
def pearls2(n): return [dict(bg='radial-gradient(circle at 34% 30%, #FFFFFF, #FFF4DC 55%, #E6CFA8)' if i < n else 'transparent', ring='0 solid transparent' if i < n else '2px solid rgba(255,244,220,0.6)') for i in range(10)]
FONTS = ''.join("@font-face{font-family:'Fredoka';font-weight:%d;src:url(file://%s/../fonts/package/files/fredoka-latin-%d-normal.woff2)}" % (wt, HERE, wt) for wt in (500, 600, 700))
FONTS += "@font-face{font-family:'Baloo 2';font-weight:700;src:url(file:///tmp/claude-0/-home-claude/3c6f3ca7-db39-5b37-a5f0-d5ee91c9805a/scratchpad/fonts/x_fontsource-baloo-2-5.3.0.tgz/package/files/baloo-2-latin-700-normal.woff2)}@font-face{font-family:'Andika';font-weight:700;src:url(file:///tmp/claude-0/-home-claude/3c6f3ca7-db39-5b37-a5f0-d5ee91c9805a/scratchpad/fonts/x_fontsource-andika-5.3.0.tgz/package/files/andika-latin-700-normal.woff2)}@font-face{font-family:'Nunito';font-weight:800;src:url(file:///tmp/claude-0/-home-claude/3c6f3ca7-db39-5b37-a5f0-d5ee91c9805a/scratchpad/fonts/x_fontsource-nunito-5.3.0.tgz/package/files/nunito-latin-800-normal.woff2)}"
FONTS += "@font-face{font-family:'Baloo 2';font-weight:500;src:url(file:///tmp/claude-0/-home-claude/3c6f3ca7-db39-5b37-a5f0-d5ee91c9805a/scratchpad/fonts/x_fontsource-baloo-2-5.3.0.tgz/package/files/baloo-2-latin-500-normal.woff2)}@font-face{font-family:'Baloo 2';font-weight:600;src:url(file:///tmp/claude-0/-home-claude/3c6f3ca7-db39-5b37-a5f0-d5ee91c9805a/scratchpad/fonts/x_fontsource-baloo-2-5.3.0.tgz/package/files/baloo-2-latin-600-normal.woff2)}"
BLOBS.update({'85f2769c8ea6bce745b4b248d5cb2777': 'home_bg0.jpg', 'f7771445c3a40b09570e5e214cc5b46b': 'home_kelp_far.webp', 'a6bdf8c2e4cf73d2f9eb29c7b31fca0c': 'home_kelp_mid.webp', '1fb44619fea3c3c6e647605f73bc90b5': 'home_kelp_left.webp', '106beab6f37ef200fe0d0e5028696b82': 'home_kelp_right.webp', '8b8eda2ea0fb1fa40bf6c2d5f0c0480b': 'home_fg.webp', 'd53b3f52af3d46e83496eaa9775b4ee6': 'home_grass.png', 'eabb2f1c24c6782e415c560fd9b1f8aa': 'wordmark.png', 'a1efd4659cb3588a1718475e8ad21ce2': 'm_ophelia_hair.png', '5a35d1e9f5d04258c45f64304c8137e5': 'm_ophelia_fluke.png', '8d17984c58161afb19d710dcbf2b9d7d': 'm_ophelia_tail.png', 'b3a266604620de6faa0dc2d92e8f2155': 'm_ophelia_arm.png', '7f2c442270db4a7e67522e1b759f7734': 'm_ophelia_body.png', 'b56b9f87113625a14823299a5024e4c3': 'm_ophelia_eyes.png', '37ddf2ca20f47bba99744a4638930ce9': 'm_ophelia_shut.png', '2f6cae54cf2a03497ffa63436517ed1f': 'm_daphne_hair.png', '426c9a054e5623e17d991fb16d4de825': 'm_daphne_fluke.png', '328fe6d30130abd3ba536f71035e1ef6': 'm_daphne_tail.png', 'f85132efe35627000a0ae2eed03eb002': 'm_daphne_arm.png', 'd923df0efa9b12327851038d3d18a914': 'm_daphne_body.png', 'cd5df2a69d42f338aac3943336570230': 'm_daphne_eyes.png', '7e5c2c1208377c2b0fae329467a698b4': 'm_daphne_shut.png', '6872b147f5c0a6202efc2697e8f087f6': 'm_violet_hair.png', 'e074609282741a4716edb2531f6dce07': 'm_violet_fluke.png', '63b32310034b9a8c890a78e03ca69a38': 'm_violet_tail.png', 'ac7c00edca3a7b89497079676ee7c7c3': 'm_violet_arm.png', 'b8b290de8b5703a7f89ba3156bdbdb5a': 'm_violet_body.png', 'c6f4d5ea9508da2280ee38ebd01f9764': 'm_violet_eyes.png', '2534606c6c2eb055e7be1255906a410b': 'm_violet_shut.png'})
BLOBS.update({'859059925d0e0c4f9bf164de5c8f52ed': 'wordmark_navy.png', '1596ad657d453a2f355d115d57de231d': 'wordmark_pearl.png', '4624928b079efc9c295d7e3e3e0f183c': 'app_icon.png'})
BLOBS.update({'3f89f164e71d10fc7d282215ea9d36eb': 'wm3_navy.png', '12b78ad478e6a8ae18bfff41f66d29ae': 'wm3_navy_base.png', '15ab3ec93ecd7fe21b48106dea98570e': 'wm3_tail.png', 'c1efd10d6a8ccb5bbeea16d54abd5853': 'wm3_plus.png', '6701b10fa68b4b0f911bff6636a8da9e': 'wm3_pearl.png', '32eb8d463d556626bca31235c9931fe1': 'wm3_lower.png', 'e78f84c61d7d809fbd600ba6360e0490': 'app_icon3.png'})
BLOBS.update({'89359ea3f4917faec79abfec1ec9070d': 'wm4_navy.png', '25773409c2a956677a15d1ce8489b9dd': 'wm4_text.png', '2d86086017b50878ebc538677c7800af': 'wm4_body.png', '7d5a17cfadefe413418b0f77b448af80': 'wm4_fin.png', '17a0c005231c895722b744bfa4bc7a0c': 'wm4_plus.png', '8eb02bdc471812a6b6f45940428444b9': 'wm4_pearl.png', '8c7622177e93ad5389735dfadcbe3c91': 'wm4_lower.png', 'a5d5ddcd4843b0f96c346b8032d916d8': 'app_icon4.png', '2775762894a6f490e6971d312ac1159c': 'm_daphne_hair.png', '03a7cfba28116eead93a24fbecfc2282': 'm_daphne_pigl.png', '16cd6dd1b570da5f59d46c7ba09ff948': 'm_daphne_pigr.png'})
BLOBS.update({'e6f82b01f2b860112cd5382ee65d7ca1': 'wm5_navy.png', '5f5ea5bda889e8561700202e736c667a': 'wm5_text.png', '30cfccb044799f040ef2096fcaaf6b58': 'wm5_math.png', '29924a1394dbe9d90db13f7aa74312fc': 'wm5_body.png', 'f9a6b9f505df8d8949e3831ba693fd95': 'wm5_fin.png', '59c582967524124fb18cfe9be6e91197': 'wm5_pearl.png', 'fbf6b7d7f5265f846c3b2b501211bff2': 'wm5_alt.png', 'a3e947ad385b9c6d9a95f4276fd787a6': 'app_icon5.png'})
BLOBS.update({'3c8b23defca2f0d0689ddc51528ac847': 'coral_bg.jpg', '107610101ab6f994bfa013c3a983ab00': 'coral_kelp_far.webp', '48b9a6cca1a39917361188afbc76b39e': 'coral_fan_left.webp', 'a7b2cb95df3ebe848eca241b5b0a4c62': 'coral_fan_right.webp', '233d69723e098944e97005b11407a0dc': 'coral_fg.webp', '6872dec9382fa4c07498004290cfd410': 'coral_grass.png', 'cc074b84035e55f744ec8d5d27246b2a': 'shell_orange_p.png', 'f2911e9bc4fbb9ffb1a3b3374120b0f1': 'shell_teal_p.png', '1e6ce328c3c5b61238dcb60ee27bca1a': 'map_bg.jpg', '70c5aede73810f30790aef690971e4ee': 'map_kelp_far.webp', '32b37f7155f4fcf03b81f05c0555a974': 'map_kelp_mid.webp', '4116c6e2df7440d70df945fcacc92db3': 'map_floor.webp', '940c1abb01ad23492313877861a16b5e': 'map_grass.png', 'c95699f3f2b55545c3ba33edc21f3cdb': 'props_lock.png', 'c8b55be8c2584ee5dfcc7aa7d2703ce9': 'chest_bg.jpg', '6a4c44ebb1b3231c86d2086cb6718af0': 'chest_kelp_far.webp', '72a79a30ff786e29ee7a94632f2995cb': 'chest_kelp_mid.webp', '366a05ba76018014226e552455fbab08': 'chest_fg.webp', '85513cd06ec25d24c6142645ba3a5fd0': 'chest_grass.png', '3a89cacc663e039a366ae56924b2919b': 'chest_chest_lid.png', 'b1c459b35a0916bf8cb3c1ac67a4afae': 'chest_chest_box.png', 'eac161cfbb26dd77788001959082c7d4': 'chest_lamp.png', '9ad71387a6dcb0615791201c4a77fec9': 'chest_lamp_face.png', '8b74ac39a06cf29c6337546f829a7c6f': 'grotto_bg.jpg', '6a52c8d8e1d3125fdeb1af2310092e32': 'grotto_floor.webp', '97538b44c48b6c7537c65f38967baa40': 'grotto_walls.webp', 'f4a6a53d6b5b0410769efeaa5be8ef8d': 'grotto_curtain.webp', '44bfe3d76e68660183038c4b8bb68097': 'grotto_bed.png', '9f964e02793bad3f50213a2d77d6bb98': 'grotto_lights.png', 'dfbb69fdaf3c95574d57e9a86ef993fe': 'grotto_lamp.png', '4278c67bf3cd680e58bd429b7cf76a55': 'grotto_lamp_face.png'})
BLOBS.update({'f1dc7a192b9770e02b5a95285d182c32': 'coral_fg.webp', '4645ea356a627def1e204d3589407932': 'coral_grass.png'})
CTX = {
    'Wordmark': {},
    'TypeTest': {},
    'StyleFrame': dict(pearlsOn=[{}]*9, pearlsOff=[{}], pop='', bubbles=[dict(n=n, bg=GLASS, shadow=SH, opacity='1') for n in (2, 4, 7)], showHint=False, solved=False),
    'StyleFrame@hint': dict(pearlsOn=[{}]*9, pearlsOff=[{}], pop='', bubbles=[dict(n=n, bg=GLASS, shadow=SH, opacity='0.45' if n == 7 else '1') for n in (2, 4, 7)], showHint=True, solved=False),
    'StyleFrame@solved': dict(pearlsOn=[{}]*10, pearlsOff=[], pop='', bubbles=[dict(n=n, bg=GOLD2 if n == 4 else GLASS, shadow=SH + (', 0 0 44px rgba(255,210,122,0.95)' if n == 4 else ''), opacity='1') for n in (2, 4, 7)], showHint=False, solved=True),
    'Main': {}, 'Map': {}, 'Grotto': {}, 'Palette': {},
    'TidePool': dict(pearls=pearls(9), bubbles=[dict(n=n, bg=ORB, glow=GLOW, opacity='0.4' if n == 7 else '1') for n in (2, 4, 7)], showHint=True, solved=False),
    'CoralReef': dict(pearls=pearls(10), bubbles=[dict(n=n, bg=GOLD if n == 5 else ORB, glow=GLOW, opacity='1') for n in (4, 5, 6)], showHint=False, solved=True, answer='5'),
    'Chest': dict(pearls=pearls(10)),
}

def expand(name):
    src = open(os.path.join(PROJ, name.split('@')[0] + '.dc.html')).read()
    body = re.search(r'<x-dc>(.*)</x-dc>', src, re.S).group(1)
    helmet = re.search(r'<helmet>(.*?)</helmet>', body, re.S).group(1)
    body = re.sub(r'<helmet>.*?</helmet>', '', body, flags=re.S)
    ctx = CTX[name]
    def loop(m):
        out = ''
        for it in ctx[m.group(1)]:
            out += re.sub(r'\{\{' + m.group(2) + r'\.(\w+)\}\}', lambda k: str(it.get(k.group(1), '')), m.group(3))
        return out
    body = re.sub(r'<sc-for list="\{\{(\w+)\}\}" as="(\w+)"[^>]*>(.*?)</sc-for>', loop, body, flags=re.S)
    body = re.sub(r'<sc-if value="\{\{(\w+)\}\}"[^>]*>(.*?)</sc-if>', lambda m: m.group(2) if ctx[m.group(1)] else '', body, flags=re.S)
    body = re.sub(r'\{\{(\w+)\}\}', lambda m: str(ctx.get(m.group(1), '')), body)
    body = re.sub(r'/_blob/([0-9a-f]{32})', lambda m: 'file://' + os.path.join(ART, BLOBS[m.group(1)]), body)
    path = os.path.join(OUT, f'preview_{name}.html')
    open(path, 'w').write(f'<!doctype html><html><head><meta charset="utf-8">{helmet}<style>{FONTS}</style></head><body>{body}</body></html>')
    return path

import sys
ONLY = sys.argv[1:]
with sync_playwright() as p:
    b = p.chromium.launch(executable_path='/usr/bin/google-chrome', args=['--no-sandbox', '--allow-file-access-from-files'])
    for name in (ONLY or CTX):
        pg = b.new_page(viewport={'width': 800, 'height': 600}, device_scale_factor=1.5)
        try:
            pg.goto('file://' + expand(name), wait_until='load', timeout=8000)
        except Exception as e:
            print('goto', name, type(e).__name__)
        pg.wait_for_timeout(400)
        pg.screenshot(path=os.path.join(OUT, f'preview_{name}.png'))
        if name in ('StyleFrame', 'Main'):
            pg.wait_for_timeout(2600); pg.screenshot(path=os.path.join(OUT, f'preview_{name}_t2.png'))
            pg.wait_for_timeout(9000); pg.screenshot(path=os.path.join(OUT, f'preview_{name}_t3.png'))
        pg.close()
    b.close()
print('ok')
