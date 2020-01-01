import pandas as pd
import numpy as np

import matplotlib
import matplotlib.pyplot as plt
import matplotlib.ticker as ticker
import matplotlib.animation as animation
Writer = animation.FFMpegWriter(fps=5, metadata=dict(artist='Me'), bitrate=1800)
plt.rcParams['animation.ffmpeg_path'] = 'C:/FFmpeg/bin/ffmpeg.exe'
import matplotlib.colors as mc
import colorsys
from random import randint
import re
import sys

#df = pd.read_csv("data/diskistats_season2009.csv")
df = pd.read_csv("data/diskistats_calendar2010.csv")

# df = df.loc[df['Variable'] == 'GDP per capita in USA 2005 PPPs']
#
# df = df[((df.Country != 'OECD - Total') & (df.Country != 'Non-OECD Economies') & (df.Country != 'World') & (
#             df.Country != 'Euro area (15 countries)'))]
# df.to_csv(r'data/nkeh.csv')
# sys.exit(0)
df = df[['club', 'year', 'goals']]

df = df.pivot(index='club', columns='year', values='goals')

df = df.reset_index()

for p in range(3):
    i = 0
    while i < len(df.columns):
        try:
            a = np.array(df.iloc[:, i + 1])
            b = np.array(df.iloc[:, i + 2])
            c = (a + b) / 2
            df.insert(i + 2, str(df.iloc[:, i + 1].name) + '^' + str(len(df.columns)), c)
        except:
            print(f"\n  Interpolation No. {p + 1} done...")
        i += 2

df = pd.melt(df, id_vars='club', var_name='year')

frames_list = df["year"].unique().tolist()
for i in range(10):
    frames_list.append(df['year'].iloc[-1])


def transform_color(color, amount=0.5):
    try:
        c = mc.cnames[color]
    except:
        c = color
        c = colorsys.rgb_to_hls(*mc.to_rgb(c))
    return colorsys.hls_to_rgb(c[0], 1 - amount * (1 - c[1]), c[2])


all_names = df['club'].unique().tolist()
random_hex_colors = []
for i in range(len(all_names)):
    random_hex_colors.append('#' + '%06X' % randint(0, 0xFFFFFF))

rgb_colors = [transform_color(i, 1) for i in random_hex_colors]
rgb_colors_opacity = [rgb_colors[x] + (0.825,) for x in range(len(rgb_colors))]
rgb_colors_dark = [transform_color(i, 1.12) for i in random_hex_colors]

fig, ax = plt.subplots(figsize=(36, 20))

num_of_elements = 8


# normal_colors = {'Ajax Cape Town': (0.6666666666666666, 0.4745098039215686, 0.5254901960784314, 0.825), 'Amazulu': (0.5686274509803921, 0.23921568627450981, 0.1215686274509804, 0.825), 'Baroka FC': (0.3843137254901961, 0.49411764705882344, 0.16078431372549018, 0.825), 'Bidvest Wits': (0.4313725490196081, 0.7607843137254899, 0.3333333333333335, 0.825), 'Black Leopards': (0.5490196078431372, 0.5960784313725489, 0.1843137254901961, 0.825), 'Bloemfontein Celtic': (0.6392156862745096, 0.14901960784313728, 0.5803921568627448, 0.825), 'Cape Town City': (0.7215686274509799, 0.09411764705882353, 0.8078431372549019, 0.825), 'Chippa United': (0.3725490196078431, 0.49019607843137253, 0.34117647058823525, 0.825), 'Free State Stars': (0.9019607843137254, 0.219607843137255, 0.2901960784313728, 0.825), 'Golden Arrows': (0.29803921568627434, 0.9764705882352942, 0.36078431372549014, 0.825), 'Highlands Park': (0.4156862745098039, 0.5098039215686274, 0.38431372549019605, 0.825), 'Jomo Cosmos': (0.41960784313725485, 0.8980392156862745, 0.7215686274509805, 0.825), 'Kaizer Chiefs': (0.9294117647058824, 0.8117647058823529, 0.14901960784313717, 0.825), 'Mamelodi Sundowns': (0.33333333333333337, 0.9764705882352941, 0.7254901960784316, 0.825), 'Maritzburg United': (0.8431372549019609, 0.615686274509804, 0.7529411764705882, 0.825), 'Moroka Swallows': (0.07843137254901966, 0.7058823529411765, 0.0862745098039218, 0.825), 'Mpumalanga Black Aces': (0.7450980392156863, 0.30980392156862746, 0.5254901960784311, 0.825), 'Orlando Pirates': (0.8823529411764706, 0.5725490196078431, 0.015686274509803866, 0.825), 'Platinum Stars': (0.4823529411764706, 0.5450980392156862, 0.15294117647058825, 0.825), 'Polokwane City': (0.4627450980392155, 0.9372549019607844, 0.8862745098039215, 0.825), 'Santos': (0.9607843137254902, 0.6823529411764706, 0.35686274509803917, 0.825), 'Stellenbosch ': (0.4627450980392157, 0.2313725490196078, 0.388235294117647, 0.825), 'SuperSport United': (0.5019607843137256, 0.21568627450980393, 0.592156862745098, 0.825), 'University of Pretoria': (0.2549019607843137, 0.3568627450980391, 0.7019607843137254, 0.825), 'Vasco da Gama': (0.23921568627450973, 0.8470588235294118, 0.24705882352941164, 0.825)}

normal_colors = {'Ajax Cape Town': ('#ffffff')
    , 'Amazulu': ('#13af4d')
    , 'Baroka FC': ('#119e50')
    , 'Bidvest Wits': ('#3a3864')
    , 'Black Leopards': ('#f6b420')
    , 'Bloemfontein Celtic': ('#0f9441')
    , 'Cape Town City': ('#0033a0')
    , 'Chippa United': ('#2470ad')
    , 'Free State Stars': ('#db221d')
    , 'Golden Arrows': ('#2b7d3b')
    , 'Highlands Park': ('#d2232a')
    , 'Jomo Cosmos': ('#dd2e1c')
    , 'Kaizer Chiefs': ('#f4b834')
    , 'Mamelodi Sundowns': ('#fdec17')
    , 'Maritzburg United': ('#062fd1')
    , 'Moroka Swallows': ('#5e0027')
    , 'Mpumalanga Black Aces': ('#065ea3')
    , 'Orlando Pirates': ('#ffffff')
    , 'Platinum Stars': ('#8ab13c')
    , 'Polokwane City': ('#ed632c')
    , 'Santos': ('#f9d716')
    , 'Stellenbosch ': ('#6e0c2c')
    , 'SuperSport United': ('#083a76')
    , 'University of Pretoria': ('#eb203d')
    , 'Vasco da Gama': ('#fdf3f3')
                 }

dark_colors = {'Ajax Cape Town': ('#ba0a22')
    , 'Amazulu': ('#ffffff')
    , 'Baroka FC': ('#f5de2d')
    , 'Bidvest Wits': ('#ffffff')
    , 'Black Leopards': ('#000000')
    , 'Bloemfontein Celtic': ('#ffffff')
    , 'Cape Town City': ('#cd9700')
    , 'Chippa United': ('#ffffff')
    , 'Free State Stars': ('#2b2771')
    , 'Golden Arrows': ('#feda0c')
    , 'Highlands Park': ('#fbe90a')
    , 'Jomo Cosmos': ('#231769')
    , 'Kaizer Chiefs': ('#000000')
    , 'Mamelodi Sundowns': ('#00ac64')
    , 'Maritzburg United': ('#ff0204')
    , 'Moroka Swallows': ('#ffffff')
    , 'Mpumalanga Black Aces': ('#000000')
    , 'Orlando Pirates': ('#000000')
    , 'Platinum Stars': ('#223548')
    , 'Polokwane City': ('#000000')
    , 'Santos': ('#cc0c01')
    , 'Stellenbosch ': ('#cf9d42')
    , 'SuperSport United': ('#e2a61b')
    , 'University of Pretoria': ('#005ca9')
    , 'Vasco da Gama': ('#ffffff')
                 }

def draw_barchart(year):
    df_frame = df[df['year'].eq(year)].sort_values(by='value', ascending=True).tail(num_of_elements)
    ax.clear()

    # normal_colors = dict(zip(df['Country'].unique(), rgb_colors_opacity))
    # dark_colors = dict(zip(df['Country'].unique(), rgb_colors_dark))

    ax.barh(df_frame['club'], df_frame['value'], color=[normal_colors[x] for x in df_frame['club']], height=0.8,
            edgecolor=([dark_colors[x] for x in df_frame['club']]), linewidth='6')

    dx = float(df_frame['value'].max()) / 200

    for i, (value, name) in enumerate(zip(df_frame['value'], df_frame['club'])):
        ax.text(value + dx, i + (num_of_elements / 50), '    ' + name,
                size=36, weight='bold', ha='left', va='center', fontdict={'fontname': 'Trebuchet MS'})
        ax.text(value + dx, i - (num_of_elements / 50), f'    {value:,.0f}', size=36, ha='left', va='center')

    time_unit_displayed = re.sub(r'\^(.*)', r'', str(year))
    ax.text(1.25, 0.05, time_unit_displayed, transform=ax.transAxes, color='#666666',
            size=162, ha='right', weight='bold', fontdict={'fontname': 'Trebuchet MS'})
    ax.text(1.30, 0.02, 'by @diskistats; inspired by @6berardi/@pratapvardhan', transform=ax.transAxes, color='#acacac',
            size=20, ha='right', fontdict={'fontname': 'Trebuchet MS'})
    ax.text(-0.005, 1.06, 'top 8', transform=ax.transAxes, size=30, color='#666666')
    ax.text(-0.005, 1.14, 'A decade of PSL goals scored', transform=ax.transAxes,
            size=62, weight='bold', ha='left', fontdict={'fontname': 'Trebuchet MS'})

    ax.xaxis.set_major_formatter(ticker.StrMethodFormatter('{x:,.0f}'))
    ax.xaxis.set_ticks_position('top')
    ax.tick_params(axis='x', colors='#666666', labelsize=28)
    ax.set_yticks([])
    ax.set_axisbelow(True)
    ax.margins(0, 0.01)
    ax.grid(which='major', axis='x', linestyle='-')

    plt.locator_params(axis='x', nbins=4)
    plt.box(False)
    plt.subplots_adjust(left=0.075, right=0.75, top=0.825, bottom=0.05, wspace=0.2, hspace=0.2)
    plt.rcParams['animation.ffmpeg_path'] = "C:\FFmpeg\bin\ffmpeg.exe"

animator = animation.FuncAnimation(fig, draw_barchart, frames=frames_list)
animator.save("Racing Bar Chart Diski.mp4",  writer=Writer)