# [MoCap Toolbox](https://github.com/mocaptoolbox/mocaptoolbox)

## Analysis and visualization of motion capture data in MATLAB

The MoCap Toolbox is a [MATLAB®](http://www.mathworks.com/) toolbox that contains functions for the analysis and visualization of motion capture data. The toolbox is mainly aimed for the analysis of music-related movement, but might be useful in other areas of study as well. It supports the generic .c3d file format, the .tsv data format produced by the [Qualisys Motion Capture system](http://www.qualisys.com/), the .mat file format produced by the Qualisys Motion Capture system, the .bvh format, and the .wii format produced by the [WiiDataCapture](https://github.com/mocaptoolbox/WiiDataCapture) software. Check out the **[MoCap Toolbox documentation](https://github.com/mocaptoolbox/mocaptoolbox/wiki)** to learn more.

To use the toolbox, you need the [MATLAB]((http://www.mathworks.com/)) software. Before using it, the toolbox has to be added in the MATLAB path variable. The toolbox should be compatible with most versions of MATLAB and most platforms. The latest implementations and developments have been made on MATLAB R2021a running on macOS 11.6.4.
The MoCap Toolbox comes with no warranty. It is free software, and you are welcome to redistribute it under certain conditions. See the file License.txt provided with the toolbox for details of GNU General Public License.



### Authors
[Petri Toiviainen](http://users.jyu.fi/~ptoiviai/) (Professor) and [Martin Hartmann](http://users.jyu.fi/~maarhart/) (Assistant Professor) are employed at the Department of Music, Art and Culture Studies of the University of Jyväskylä, Finland. Both are members of the [Centre of Excellence in Music, Mind, Body and Brain](https://www.aka.fi/en/research-funding/programmes-and-other-funding-schemes/finnish-centres-of-excellence/new-centres-of-excellence/centre-of-excellence-in-music-mind-body-and-brain/), which investigates various issues related with embodied music cognition. [Birgitta Burger](https://www.linkedin.com/in/birgitta-burger/) (independent researcher) is an affiliate member of the Centre of Excellence in Music, Mind, Body and Brain. She has been fundamental to the development and support of the Mocap Toolbox.

If you have any comments or problems to report, please contact Petri Toiviainen or Martin Hartmann (`firstname.lastname at jyu.fi`).
### Download

#### [Click here to download the latest release of MoCap Toolbox.](https://github.com/mocaptoolbox/mocaptoolbox/releases)

Alternatively, you can check out our [main development branch](https://github.com/mocaptoolbox/mocaptoolbox). To clone it via Git:

`git clone https://github.com/mocaptoolbox/mocaptoolbox.git`

### Extensions / Add ons

#### [mcarray](https://github.com/krisny/mcarray)

Array extensions for the Mocap Toolbox (Kristian Nymoen).

#### [MCT Extras](https://github.com/krisny/mct-extras)

Extensions and alternative functions for the Mocap Toolbox (Kristian Nymoen).

#### [MusicMocapMatlab](https://github.com/olivierlar/MusicMocapMatlab)

Various Matlab tools for analysing audio and mocap data (Kristian Nymoen and Olivier Lartillot)

#### [Eye tracker add on](https://github.com/mocaptoolbox/EyetrackerAddOn)
This add on reads in Ergoneers Dikablis eye tracker data and syncs it to mocap recordings. More information on how to use the functions will follow soon.

#### [Periodic Quantity of Motion](https://github.com/mocaptoolbox/periodic-quantity-of-motion)

Periodic quantity of motion by Rodrigo Schramm & Federico Visi. You need MoCap Toolbox to run the functions. See the [Manual](https://github.com/mocaptoolbox/mocaptoolbox/wiki) and the function help how to use it.

See also: Visi, Federico, Schramm, Rodrigo and Miranda, Eduardo. Gesture in Performance with Traditional Musical Instruments and Electronics: Use of Embodied Music Cognition and Multimodal Motion Capture to Design Gestural Mapping Strategies. _Proceedings of the International Workshop on Movement and Computing. MOCO '14_, p. 100-105, ACM, Paris, 2014.

#### [WiiDataCapture](https://github.com/mocaptoolbox/WiiDataCapture)

WiiDataCapture is a software that displays and saves acceleration data of up to 8 Nintendo Wiimotes. Version 2.2 also features audio playback (from line in input or computer) and audio recording.

The WiiDataCapture 2.2 utility runs on Mac OS X until v10.12 (Sierra) with both Osculator 2 and 3. If the Wiimote refuses to pair with the computer, try restarting the computer.

WiiDataCapture 2.2 requires [OSCulator](http://www.osculator.net)!

Old versions of WiiDataCapture: please contact authors for older versions.

## Mailing List
Please register to the mailing list to stay informed about new releases, bug reports, and bug fixes. It also serves as a general discussion board for users, so feel free to post anything motion capture- and toolbox-related that might be of interest to other users and developers. 

[Subscribe to mailing list](https://www.freelists.org/list/mocaptoolbox)

You can also sign up to GitHub and participate in our [Discussions](https://github.com/mocaptoolbox/mocaptoolbox/discussions), report [issues](https://github.com/mocaptoolbox/mocaptoolbox/issues) and create [pull requests](https://github.com/mocaptoolbox/mocaptoolbox/pulls).

### Documentation and Reference
The [documentation](https://github.com/mocaptoolbox/mocaptoolbox/wiki) provides a general description of the Toolbox (Chapter 1) and examples (Chapter 2). Chapter 3 and 4 contain the data and parameter structure, and function reference respectively.

To cite the MoCap Toolbox, please use the following reference:

#### APA entry:
Burger, B. & Toiviainen, P. (2013). MoCap Toolbox – A Matlab toolbox for computational analysis of movement data. In R. Bresin (Ed.), _Proceedings of the 10th Sound and Music Computing Conference_, (SMC). Stockholm, Sweden: KTH Royal Institute of Technology.
#### Bibtex entry:
`@inproceedings{BurgerToiviainen2013,
address = {Stockholm, Sweden},
author = {Burger, Birgitta and Toiviainen, Petri},
booktitle = {Proceedings of the 10th Sound and Music Computing Conference},
editor = {Bresin, Roberto},
pages = {172--178},
publisher = {KTH Royal Institute of Technology},
title = {{MoCap Toolbox -- A Matlab toolbox for computational analysis of movement data}},
year = {2013}}`

Download the [article](https://www.jyu.fi/hytk/fi/laitokset/mutku/en/research/materials/mocaptoolbox/MocapToolboxProceeding) (pdf)



### Installation
Unpack the MoCap Toolbox file package you have downloaded. This will create a directory called mocaptoolbox. Secondly, a version of the [MATLAB](www.mathworks.com) program needs to be installed. Thirdly, the Toolbox needs to be defined in the MATLAB path variable. Under the File menu, select Set Path Under the Path menu, select Add to Path. Write here the name of the directory where this toolbox has been installed. Then click OK. Finally, under the File menu, select Save Path, and then Exit.



### Compatibility
Macintosh (OS X): The MoCap Toolbox is compatible with most recent MATLAB versions and has been tested with 8.4. (R2014b) running on Macintosh OS X v10.10 and higher.
Linux/Windows: Currently not tested but should be compatible.
