[![Build status](https://ci.appveyor.com/api/projects/status/q22icjwv5h5bonav/branch/master?svg=true)](https://ci.appveyor.com/project/Jhobean/cryptocore-f7p6q/branch/master) (Appveyor)

[![Build Status](https://travis-ci.com/Cryptonite-UO/CryptoCore.svg?branch=master)](https://travis-ci.com/Cryptonite-UO/CryptoCore) (Travis)

[![Codacy Badge](https://api.codacy.com/project/badge/Grade/a644ed6dd6be4f1cbfc27dc97ea2cab2)](https://app.codacy.com/gh/Cryptonite-UO/CryptoCore?utm_source=github.com&utm_medium=referral&utm_content=Cryptonite-UO/CryptoCore&utm_campaign=Badge_Grade_Settings)
# CRYPTOCORE
This Repository is a Clone of the SphereServer X version available here: [SOURCEX](https://github.com/Sphereserver/Source-X) 

## Why a clone/fork?
This version of Sphere is use on Ultima online [Resistance Shard](https://www.uoresistance.com/).
We decide to fork this branch because some little modification are made for adapting our gameplay.


#### Here the list of difference between the reel sphere X:
[Commit](https://github.com/Cryptonite-UO/ResistanceCore/commit/c296070bf72f3e0958275e6286196f103d2bb335) 2024-09-08
[Commit2](https://github.com/Cryptonite-UO/ResistanceCore/commit/dae2ad1b5e84f9886a74ba77ae2055493ae7dfab)
1.  It's now impossible to gain skillpoint with weapon skill during battle (Now script side).
2.  On @GETHIT, return 3 is a dodge and no more noise will be hear from the weapon.

[Commit](https://github.com/Cryptonite-UO/ResistanceCore/commit/39129ca395991d777c51c31391d83eaf82f692a4) 2023-03-23
1.  It's now possible to hide and detect hidden during battle. This action will result to reset all actual action.

[Commit](https://github.com/Cryptonite-UO/ResistanceCore/commit/c7bfa85ffd2362b472d70754764c87f4c982fa93) 2023-01-18
[Commit2](https://github.com/Cryptonite-UO/ResistanceCore/commit/9d729fbde3c37d7b4b3940f346f1331b1bf86721) 2024-05-08
1.  MOREY (increase MAX DAM) on weapon de not require anymore ATTRMAGIC.

[Commit](https://github.com/Cryptonite-UO/ResistanceCore/commit/1b61df4927256bd3a0ffccc8a950fd98e259357b) 2023-01-15
[Commit2](https://github.com/Cryptonite-UO/ResistanceCore/commit/1a8c02e4deb5e71055cc23f2e34f67ae4b4e005e)
1.  Now c_vampire_male and c_vampire_female can be use for a 4th race in the game. Using same anim patern than human.

[Commit3](https://github.com/Cryptonite-UO/ResistanceCore/commit/776269615d6474fd4d637040885972c5f45ee81d)
1.  Str now contribute in dammage with 1% of value instead of 10%. 

[Commit](https://github.com/Cryptonite-UO/ResistanceCore/commit/445181024855e3733d3c79f8f805ec1e46759751) 2022-11-23
1.  Animal trainer do not offer anymore the choice to stable or retrieve pet because it's done on script side.

[Commit](https://github.com/Cryptonite-UO/ResistanceCore/commit/407fd259eaa5ed43a748b5405ae7582e4b56cbc8) 2022-08-26
1.  Custom maxweight calculation because STR of player is greater.

[Commit](https://github.com/Cryptonite-UO/ResistanceCore/commit/940a70dfbf07d5d713b1b8afff5738ad8af95b00) 2021-01-10
1.  Insubtantial flags is use on some class (CL) you can now pass trought him. (partial Revert of commit of december)

[Commit](https://github.com/Cryptonite-UO/ResistanceCore/commit/646bd299a0680b02bf70a12f36c703fd925f8796) 2020-12-10
1.  Resistance use c_gargoyle_male and female as custom dwarf. We need to avoid the gargoyle anim and force human anim.
2.  Insubtantial flags is use on some class (CL) during a small period. We must modify  that the player is see like a death player.
3.  Emote message over NPC/player head is crap and long. "YOU SEE NAME" is useless. We remove all name and pronom. (important to modify msg.scp in script too)
