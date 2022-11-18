/*
Playlist manager

Dev:
 Ernesto Cesario
*/

//element size
.equ size_music_pos, 2
.equ size_music_artist, 30+1 //including null byte
.equ size_music_title, 40+1 //including null byte
.equ size_music_duration, 1

//element offset
.equ offset_music_pos, 0
.equ offset_music_artist, offset_music_pos + size_music_pos
.equ offset_music_title, offset_music_artist + size_music_artist
.equ offset_music_duration_minutes, offset_music_title + size_music_title
.equ offset_music_duration_seconds, offset_music_duration_minutes + size_music_duration
.equ music_size, offset_music_duration_seconds + size_music_duration

//Const int
.equ additional_space, 20 //number of music to add for recall realloc (use a linear space allocation)
.equ shuffle_multiplier, 100 //A big shuffle_multiplier equals better music shuffling but more computation
.equ ANIMATION_DELAY, 175000
.equ IMG_CREDITS_SIZE, 3391
.equ REPEAT_CREDITS, 3

.section .rodata

MAXSECONDS_FP:  .double 60.0
//file fmt
file_w_str: .asciz "w"
file_r_str: .asciz "r"

//printf/scanf formatter
sfmt_2byte_int:   .asciz "%hd"
pfmt_str:   .asciz "%s"
sfmt_str:   .asciz " %[^\n]1023s"

//Const str
sys_clear_str:  .asciz "clear"
FLNAME_EXT_STR: .asciz ".dat"

INTRO_STR:  .asciz " _______   __                      __  __              __            __       __                                                             \n|       \\ |  \\                    |  \\|  \\            |  \\          |  \\     /  \\                                                            \n| $$$$$$$\\| $$  ______   __    __ | $$ \\$$  _______  _| $$_         | $$\\   /  $$  ______   _______    ______    ______    ______    ______  \n| $$__/ $$| $$ |      \\ |  \\  |  \\| $$|  \\ /       \\|   $$ \\        | $$$\\ /  $$$ |      \\ |       \\  |      \\  /      \\  /      \\  /      \\ \n| $$    $$| $$  \\$$$$$$\\| $$  | $$| $$| $$|  $$$$$$$ \\$$$$$$        | $$$$\\  $$$$  \\$$$$$$\\| $$$$$$$\\  \\$$$$$$\\|  $$$$$$\\|  $$$$$$\\|  $$$$$$\\\n| $$$$$$$ | $$ /      $$| $$  | $$| $$| $$ \\$$    \\   | $$ __       | $$\\$$ $$ $$ /      $$| $$  | $$ /      $$| $$  | $$| $$    $$| $$   \\$$\n| $$      | $$|  $$$$$$$| $$__/ $$| $$| $$ _\\$$$$$$\\  | $$|  \\      | $$ \\$$$| $$|  $$$$$$$| $$  | $$|  $$$$$$$| $$__| $$| $$$$$$$$| $$      \n| $$      | $$ \\$$    $$ \\$$    $$| $$| $$|       $$   \\$$  $$      | $$  \\$ | $$ \\$$    $$| $$  | $$ \\$$    $$ \\$$    $$ \\$$     \\| $$      \n \\$$       \\$$  \\$$$$$$$ _\\$$$$$$$ \\$$ \\$$ \\$$$$$$$     \\$$$$        \\$$      \\$$  \\$$$$$$$ \\$$   \\$$  \\$$$$$$$ _\\$$$$$$$  \\$$$$$$$ \\$$      \n                        |  \\__| $$                                                                             |  \\__| $$                    \n                         \\$$    $$                                                                              \\$$    $$                    \n                          \\$$$$$$                                                                                \\$$$$$$                     \n\n\n\n"

MENU_STR:   .ascii "Choose an option: \n\n"
            .ascii "1) Add music\n"
            .ascii "2) Remove music\n"
            .ascii "3) Search music\n"
            .ascii "4) Random shuffle\n"
            .ascii "5) Calculate total playlist length\n"
            .ascii "6) Calculate average duration of track\n"
            .ascii "7) Change playlist\n"
            .ascii "8) Delete playlist\n"
            .ascii "9) Credits\n"
            .asciz "0) Exit\n"

FMT_CURRENT_PLAYLIST_STR:   .asciz "Playlist selected: %s\n"
TOTALTIME_STR: .asciz "The total duration of your playlist is: "
AVGTIME_STR:    .asciz "The average duration of a music is: "
FMT_DURATION:   .asciz "%s%hd minutes and %hd seconds (%.2f minutes)\n"
CREDITS_STR:    .asciz "Developer:\n Ernesto Cesario\n"
NAME_END_STR:   .asciz "#"
DURATION_SPLITTER_STR:  .asciz ":"
NEWLINE_STR:    .asciz "\n"
NEWLINE2_STR:   .asciz "\n\n"

//Table
BORDER_HORIZ_STR:   .asciz "_______________________________________________________________________________________________________\n"
BORDER_VERT_STR:    .asciz "|  %05d  |  %-30.30s  |  %-40.40s   |  %02d:%02d   |\n"
BORDER_FMT_HEADER_STR:  .asciz "|  Index  |              Artist              |                    Music                    | Duration |\n"

//Prompt str
SEL_MENU_STR:   .asciz "? "
PROMPT_ARTIST_STR:  .asciz "Enter the artist of the song: "
PROMPT_TITLE_STR: .asciz "Enter the title of the song: "
PROMPT_DURATION_STR: .asciz "Enter the duration of the song (mm:ss): "
PROMPT_SEL_PLAYLIST_STR: .asciz "Enter the name of a playlist to load (if it does not exist it will be created, \'#\' to end): "
PROMPT_DEL_MUSIC_STR: .asciz "Enter the location of a music to delete (0 to cancel): "
PROMPT_FIND_MUSIC_STR: .asciz "Enter part of the title of the music to be searched: "
PROMPT_PRESS_KEY_STR: .asciz "\nPress a key to continue...\n"

//Error str
ERROR_DEL_PLAYLIST_STR: .asciz "Error while deleting playlist!\n"
ERROR_MEM_ALLOCATED_STR: .asciz "Unable to allocate the required amount of memory!\n"
ERROR_FILE_SAVE_STR: .asciz "Error while saving to file!\n"

//Animation credits room
IMG_0:  .asciz "                                                                                                                \n                                                                                                                \n                                          + +                                                                   \n                                          + +                                                                   \n                    + +                   + + +                                               # #               \n                    + +                   + + +                                               # #               \n                    + + +                 + + + + +                 + +                       # # #             \n                    + + +                 + + + + +                 + +                       # # #             \n                    + + + + +             + +   + +                 + + +                     # # # # #         \n                    + + + + +             + +   + +                 + + +                     # # # # #         \n                    + + * + + * *         + +                       + + + + +                 # # @ # # @ @     \n                    + + * + + * *         + +                       + + + + +                 # # @ # # @ @     \n                    + +   * * * *         + +                       + + * + + * *             # #   @ @ @ @     \n                    + +       * *         + +                       + +   * * * *             # #       @ @     \n                    + +       * *         + +                       + +   * * * *             # #       @ @     \n                    + +                   + +                       + +       * *             # #               \n                    + +                   + +                       + +       * *             # #               \n                    + +       + + + + + + + +                       + +                       # #               \n                    + +       + + + + + + + +                       + +                       # #               \n        + + + + + + + +   + +     + + + +                           + +           # # # # # # # #               \n        + + + + + + + +   + +     + + + +                           + +           # # # # # # # #               \n    + +     + + + + * *   + + + + + + + +               + + + + + + + +       # #     # # # # @ @               \n    + +     + + + + * *   + + + + + + + +               + + + + + + + +       # #     # # # # @ @               \n    + + + + + + + + * *                             + +     + + + + * *       # # # # # # # # @ @               \n        * * * * * *                                 + + + + + + + + * *           @ @ @ @ @ @                   \n        * * * * * *                                 + + + + + + + + * *           @ @ @ @ @ @                   \n                                                        * * # # * *                                             \n                                                        * * # # * *                                             \n                                                                                                                \n                                                                                                                \n"
IMG_1:  .asciz "                                                                                                                \n                    + +                                                                                         \n                    + + +                 + +                                                                   \n                    + + +                 + +                                                                   \n                    + + + + +             + + +                                               # #               \n                    + + + + +             + + +                                               # #               \n                    + + * + + * *         + + + + +                 + +                       # # #             \n                    + + * + + * *         + + + + +                 + +                       # # #             \n                    + +   * * * *         + +   + +                 + + +                     # # # # #         \n                    + +   * * * *         + +   + +                 + + +                     # # # # #         \n                    + +       * *         + +                       + + + + +                 # # @ # # @ @     \n                    + +       * *         + +                       + + + + +                 # # @ # # @ @     \n                    + +                   + +                       + + * + + * *             # #   @ @ @ @     \n                    + +                   + +                       + +   * * * *             # #       @ @     \n                    + +                   + +                       + +   * * * *             # #       @ @     \n        + + + + + + + +                   + +                       + +       * *             # #               \n        + + + + + + + +                   + +                       + +       * *             # #               \n    + +     + + + + * *       + + + + + + + +                       + +                       # #               \n    + +     + + + + * *       + + + + + + + +                       + +                       # #               \n    + + + + + + + + * *   + +     + + + +                           + +           # # # # # # # #               \n    + + + + + + + + * *   + +     + + + +                           + +           # # # # # # # #               \n        * * * * * *       + + + + + + + +               + + + + + + + +       # #     # # # # @ @               \n        * * * * * *       + + + + + + + +               + + + + + + + +       # #     # # # # @ @               \n                                                    + +     + + + + * *       # # # # # # # # @ @               \n                                                    + + + + + + + + * *           @ @ @ @ @ @                   \n                                                    + + + + + + + + * *           @ @ @ @ @ @                   \n                                                        * * # # * *                                             \n                                                        * * # # * *                                             \n                                                                                                                \n                                                                                                                \n"
IMG_2:  .asciz "                                                                                                                \n                                                                                                                \n                                          + +                                                                   \n                                          + +                                                                   \n                    + +                   + + +                                               # #               \n                    + +                   + + +                                               # #               \n                    + + +                 + + + + +                 + +                       # # #             \n                    + + +                 + + + + +                 + +                       # # #             \n                    + + + + +             + +   + +                 + + +                     # # # # #         \n                    + + + + +             + +   + +                 + + +                     # # # # #         \n                    + + * + + * *         + +                       + + + + +                 # # @ # # @ @     \n                    + + * + + * *         + +                       + + + + +                 # # @ # # @ @     \n                    + +   * * * *         + +                       + + * + + * *             # #   @ @ @ @     \n                    + +       * *         + +                       + +   * * * *             # #       @ @     \n                    + +       * *         + +                       + +   * * * *             # #       @ @     \n                    + +                   + +                       + +       * *             # #               \n                    + +                   + +                       + +       * *             # #               \n                    + +       + + + + + + + +                       + +                       # #               \n                    + +       + + + + + + + +                       + +                       # #               \n        + + + + + + + +   + +     + + + +                           + +           # # # # # # # #               \n        + + + + + + + +   + +     + + + +                           + +           # # # # # # # #               \n    + +     + + + + * *   + + + + + + + +               + + + + + + + +       # #     # # # # @ @               \n    + +     + + + + * *   + + + + + + + +               + + + + + + + +       # #     # # # # @ @               \n    + + + + + + + + * *                             + +     + + + + * *       # # # # # # # # @ @               \n        * * * * * *                                 + + + + + + + + * *           @ @ @ @ @ @                   \n        * * * * * *                                 + + + + + + + + * *           @ @ @ @ @ @                   \n                                                        * * # # * *                                             \n                                                        * * # # * *                                             \n                                                                                                                \n                                                                                                                \n"
IMG_3:  .asciz "                                                                                                                \n                                                                                                                \n                                                                                                                \n                                                                                                                \n                    + +                                                                       # #               \n                    + +                                                                       # #               \n                    + + +                                           + +                       # # #             \n                    + + +                                           + +                       # # #             \n                    + + + + +             + +                       + + +                     # # # # #         \n                    + + + + +             + +                       + + +                     # # # # #         \n                    + + * + + * *         + + +                     + + + + +                 # # @ # # @ @     \n                    + + * + + * *         + + +                     + + + + +                 # # @ # # @ @     \n                    + +   * * * *         + + + + +                 + + * + + * *             # #   @ @ @ @     \n                    + +       * *         + +   + +                 + +   * * * *             # #       @ @     \n                    + +       * *         + +   + +                 + +   * * * *             # #       @ @     \n                    + +                   + +                       + +       * *             # #               \n                    + +                   + +                       + +       * *             # #               \n                    + +                   + +                       + +                       # #               \n                    + +                   + +                       + +                       # #               \n        + + + + + + + +                   + +                       + +           # # # # # # # #               \n        + + + + + + + +                   + +                       + +           # # # # # # # #               \n    + +     + + + + * *                   + +           + + + + + + + +       # #     # # # # @ @               \n    + +     + + + + * *                   + +           + + + + + + + +       # #     # # # # @ @               \n    + + + + + + + + * *       + + + + + + + +       + +     + + + + * *       # # # # # # # # @ @               \n        * * * * * *       + +     + + + +           + + + + + + + + * *           @ @ @ @ @ @                   \n        * * * * * *       + +     + + + +           + + + + + + + + * *           @ @ @ @ @ @                   \n                          + + + + + + + +               * * # # * *                                             \n                          + + + + + + + +               * * # # * *                                             \n                                                                                                                \n                                                                                                                \n"
IMG_4:  .asciz "                                                                                                                \n                                                                                                                \n                                          + +                                                                   \n                                          + +                                                                   \n                    + +                   + + +                                               # #               \n                    + +                   + + +                                               # #               \n                    + + +                 + + + + +                 + +                       # # #             \n                    + + +                 + + + + +                 + +                       # # #             \n                    + + + + +             + +   + +                 + + +                     # # # # #         \n                    + + + + +             + +   + +                 + + +                     # # # # #         \n                    + + * + + * *         + +                       + + + + +                 # # @ # # @ @     \n                    + + * + + * *         + +                       + + + + +                 # # @ # # @ @     \n                    + +   * * * *         + +                       + + * + + * *             # #   @ @ @ @     \n                    + +       * *         + +                       + +   * * * *             # #       @ @     \n                    + +       * *         + +                       + +   * * * *             # #       @ @     \n                    + +                   + +                       + +       * *             # #               \n                    + +                   + +                       + +       * *             # #               \n                    + +       + + + + + + + +                       + +                       # #               \n                    + +       + + + + + + + +                       + +                       # #               \n        + + + + + + + +   + +     + + + +                           + +           # # # # # # # #               \n        + + + + + + + +   + +     + + + +                           + +           # # # # # # # #               \n    + +     + + + + * *   + + + + + + + +               + + + + + + + +       # #     # # # # @ @               \n    + +     + + + + * *   + + + + + + + +               + + + + + + + +       # #     # # # # @ @               \n    + + + + + + + + * *                             + +     + + + + * *       # # # # # # # # @ @               \n        * * * * * *                                 + + + + + + + + * *           @ @ @ @ @ @                   \n        * * * * * *                                 + + + + + + + + * *           @ @ @ @ @ @                   \n                                                        * * # # * *                                             \n                                                        * * # # * *                                             \n                                                                                                                \n                                                                                                                \n"
IMG_5:  .asciz "                                                                    + +                                         \n                                                                    + +                                         \n                                          + +                       + + +                                       \n                                          + +                       + + +                                       \n                    + +                   + + +                     + + + + +                 # #               \n                    + +                   + + +                     + + + + +                 # #               \n                    + + +                 + + + + +                 + + * + + * *             # # #             \n                    + + +                 + + + + +                 + + * + + * *             # # #             \n                    + + + + +             + +   + +                 + +   * * * *             # # # # #         \n                    + + + + +             + +   + +                 + +   * * * *             # # # # #         \n                    + + * + + * *         + +                       + +       * *             # # @ # # @ @     \n                    + + * + + * *         + +                       + +       * *             # # @ # # @ @     \n                    + +   * * * *         + +                       + +                       # #   @ @ @ @     \n                    + +       * *         + +                       + +                       # #       @ @     \n                    + +       * *         + +                       + +                       # #       @ @     \n                    + +                   + +           + + + + + + + +                       # #               \n                    + +                   + +           + + + + + + + +                       # #               \n                    + +       + + + + + + + +       + +     + + + + * *                       # #               \n                    + +       + + + + + + + +       + +     + + + + * *                       # #               \n        + + + + + + + +   + +     + + + +           + + + + + + + + * *           # # # # # # # #               \n        + + + + + + + +   + +     + + + +           + + + + + + + + * *           # # # # # # # #               \n    + +     + + + + * *   + + + + + + + +               * * # # * *           # #     # # # # @ @               \n    + +     + + + + * *   + + + + + + + +               * * # # * *           # #     # # # # @ @               \n    + + + + + + + + * *                                                       # # # # # # # # @ @               \n        * * * * * *                                                               @ @ @ @ @ @                   \n        * * * * * *                                                               @ @ @ @ @ @                   \n                                                                                                                \n                                                                                                                \n                                                                                                                \n                                                                                                                \n"
IMG_6:  .asciz "                                                                                                                \n                                                                                                                \n                                          + +                                                                   \n                                          + +                                                                   \n                    + +                   + + +                                               # #               \n                    + +                   + + +                                               # #               \n                    + + +                 + + + + +                 + +                       # # #             \n                    + + +                 + + + + +                 + +                       # # #             \n                    + + + + +             + +   + +                 + + +                     # # # # #         \n                    + + + + +             + +   + +                 + + +                     # # # # #         \n                    + + * + + * *         + +                       + + + + +                 # # @ # # @ @     \n                    + + * + + * *         + +                       + + + + +                 # # @ # # @ @     \n                    + +   * * * *         + +                       + + * + + * *             # #   @ @ @ @     \n                    + +       * *         + +                       + +   * * * *             # #       @ @     \n                    + +       * *         + +                       + +   * * * *             # #       @ @     \n                    + +                   + +                       + +       * *             # #               \n                    + +                   + +                       + +       * *             # #               \n                    + +       + + + + + + + +                       + +                       # #               \n                    + +       + + + + + + + +                       + +                       # #               \n        + + + + + + + +   + +     + + + +                           + +           # # # # # # # #               \n        + + + + + + + +   + +     + + + +                           + +           # # # # # # # #               \n    + +     + + + + * *   + + + + + + + +               + + + + + + + +       # #     # # # # @ @               \n    + +     + + + + * *   + + + + + + + +               + + + + + + + +       # #     # # # # @ @               \n    + + + + + + + + * *                             + +     + + + + * *       # # # # # # # # @ @               \n        * * * * * *                                 + + + + + + + + * *           @ @ @ @ @ @                   \n        * * * * * *                                 + + + + + + + + * *           @ @ @ @ @ @                   \n                                                        * * # # * *                                             \n                                                        * * # # * *                                             \n                                                                                                                \n                                                                                                                \n"
IMG_7:  .asciz "                                                                                                                \n                                                                                                                \n                                          + +                                                                   \n                                          + +                                                                   \n                    + +                   + + +                                                                 \n                    + +                   + + +                                                                 \n                    + + +                 + + + + +                 + +                                         \n                    + + +                 + + + + +                 + +                                         \n                    + + + + +             + +   + +                 + + +                     # #               \n                    + + + + +             + +   + +                 + + +                     # #               \n                    + + * + + * *         + +                       + + + + +                 # # #             \n                    + + * + + * *         + +                       + + + + +                 # # #             \n                    + +   * * * *         + +                       + + * + + * *             # # # # #         \n                    + +       * *         + +                       + +   * * * *             # # @ # # @ @     \n                    + +       * *         + +                       + +   * * * *             # # @ # # @ @     \n                    + +                   + +                       + +       * *             # #   @ @ @ @     \n                    + +                   + +                       + +       * *             # #   @ @ @ @     \n                    + +       + + + + + + + +                       + +                       # #       @ @     \n                    + +       + + + + + + + +                       + +                       # #       @ @     \n        + + + + + + + +   + +     + + + +                           + +                       # #               \n        + + + + + + + +   + +     + + + +                           + +                       # #               \n    + +     + + + + * *   + + + + + + + +               + + + + + + + +                       # #               \n    + +     + + + + * *   + + + + + + + +               + + + + + + + +                       # #               \n    + + + + + + + + * *                             + +     + + + + * *           # # # # # # # #               \n        * * * * * *                                 + + + + + + + + * *       # #     # # # # @ @               \n        * * * * * *                                 + + + + + + + + * *       # #     # # # # @ @               \n                                                        * * # # * *           # # # # # # # # @ @               \n                                                        * * # # * *           # # # # # # # # @ @               \n                                                                                  @ @ @ @ @ @                   \n                                                                                  @ @ @ @ @ @                   \n"
IMG_8:  .asciz "                                                                                                                \n                                                                                                                \n                                          + +                                                                   \n                                          + +                                                                   \n                    + +                   + + +                                               # #               \n                    + +                   + + +                                               # #               \n                    + + +                 + + + + +                 + +                       # # #             \n                    + + +                 + + + + +                 + +                       # # #             \n                    + + + + +             + +   + +                 + + +                     # # # # #         \n                    + + + + +             + +   + +                 + + +                     # # # # #         \n                    + + * + + * *         + +                       + + + + +                 # # @ # # @ @     \n                    + + * + + * *         + +                       + + + + +                 # # @ # # @ @     \n                    + +   * * * *         + +                       + + * + + * *             # #   @ @ @ @     \n                    + +       * *         + +                       + +   * * * *             # #       @ @     \n                    + +       * *         + +                       + +   * * * *             # #       @ @     \n                    + +                   + +                       + +       * *             # #               \n                    + +                   + +                       + +       * *             # #               \n                    + +       + + + + + + + +                       + +                       # #               \n                    + +       + + + + + + + +                       + +                       # #               \n        + + + + + + + +   + +     + + + +                           + +           # # # # # # # #               \n        + + + + + + + +   + +     + + + +                           + +           # # # # # # # #               \n    + +     + + + + * *   + + + + + + + +               + + + + + + + +       # #     # # # # @ @               \n    + +     + + + + * *   + + + + + + + +               + + + + + + + +       # #     # # # # @ @               \n    + + + + + + + + * *                             + +     + + + + * *       # # # # # # # # @ @               \n        * * * * * *                                 + + + + + + + + * *           @ @ @ @ @ @                   \n        * * * * * *                                 + + + + + + + + * *           @ @ @ @ @ @                   \n                                                        * * # # * *                                             \n                                                        * * # # * *                                             \n                                                                                                                \n                                                                                                                \n"

.data
.align 1 //useless
n_music: .2byte 0
n_max_music:    .2byte 0

.bss
//tmp var
tmp_int:    .skip 2
tmp_str:    .skip 1024

//playlist name
filename:   .skip 64 //w extension

//Macro

.macro clear_screen //Clear the screen on linux
    adr x0, sys_clear_str
    bl system
.endm

.macro printm fmt, var //Print a var with a fmt
    adr x0, \fmt
    adr x1, \var
    bl printf
.endm

.macro save_to item, offset, size //Copy a part of memory (offset) into another part (item) until (size) byte reached
    add x0, \item, \offset
    adr x1, tmp_str
    mov x2, \size
    bl strncpy

    add x0, \item, \offset + \size - 1
    strb wzr, [x0]
.endm

.macro print_duration text //Print duration with minutes in x0 and seconds in x1 and time in minute in d0, with a chosed string text
    mov x3, x1
    mov x2, x0
    adr x1, \text
    adr x0, FMT_DURATION
    bl printf
.endm

.text
.type main, %function
.global main
main:
    stp x29, x30, [sp, #-16]!
    str x19, [sp, #-16]!
    mov x19, #0 //set memptr to null

    //x19 memptr

    main_loop1:
    cmp x19, #0 //check if memptr is null
    beq endfreemem
    mov x0, x19
    bl free //free memory at memptr
    endfreemem:
    clear_screen
    printm pfmt_str, INTRO_STR
    adr x0, PROMPT_SEL_PLAYLIST_STR //Prompt filename to user
    bl read_str
    adr x1, NAME_END_STR
    bl strcmp
    cmp x0, #0 //if filename == NAME_END_STR then end program
    bne valid_name
    mov w1, #0 //ret 0
    b end_main_no_alloc //no mem allocated
    valid_name:
    adr x0, tmp_str
    bl sel_playlist //call w/arg0 filename, ret memptr
    cmp x0, #0 //check memptr
    bne succ_mem_allocated
    printm pfmt_str, ERROR_MEM_ALLOCATED_STR
    bl presskey
    mov w1, #1 //ret 1
    b end_main_no_alloc //no mem allocated
    succ_mem_allocated:
    mov x19, x0 //save memptr
    main_loop2:
    clear_screen
    printm pfmt_str, INTRO_STR
    printm FMT_CURRENT_PLAYLIST_STR, filename
    mov x0, x19
    bl draw_table //call w/arg0 memptr
    printm pfmt_str, MENU_STR
    adr x0, SEL_MENU_STR //Prompt number for menu
    bl read_str
    bl isint
    cmp x0, #0
    bne main_loop2
    adr x0, tmp_str
    bl atoi
    

    //Menu switch
    cmp x0, #1
    bne elseif1
    mov x0, x19
    bl add_music //call w/arg0 memptr
    cmp x0, #0
    bne main_endif1
    printm pfmt_str, ERROR_MEM_ALLOCATED_STR
    bl presskey
    mov w1, #1
    b end_main_no_alloc
    main_endif1:
    mov x19, x0
    b endif
    elseif1:
    cmp x0, #2
    bne elseif2
    mov x0, x19
    bl del_music
    cmp x0, #0
    bne main_endif2
    printm pfmt_str, ERROR_MEM_ALLOCATED_STR
    bl presskey
    mov w1, #1
    b end_main_no_alloc
    main_endif2:
    mov x19, x0
    b endif
    elseif2:
    cmp x0, #3
    bne elseif3
    mov x0, x19
    bl findmusic
    b endif
    elseif3:
    cmp x0, #4
    bne elseif4
    mov x0, x19
    bl shuffle
    b endif
    elseif4:
    cmp x0, #5
    bne elseif5
    mov x0, x19
    mov x1, xzr
    bl gettotaltime //call w/arg0 memptr w/arg1 0x00
    b endif
    elseif5:
    cmp x0, #6
    bne elseif6
    mov x0, x19
    bl getavgtime //call w/arg0 memptr
    b endif
    elseif6:
    cmp x0, #7
    bne elseif7
    b main_loop1 //changing playlist
    elseif7:
    cmp x0, #8
    bne elseif8
    bl del_playlist
    cmp x0, #0
    beq op_remove_succ
    printm pfmt_str, ERROR_DEL_PLAYLIST_STR
    bl presskey
    b main_loop2
    op_remove_succ:
    b main_loop1
    elseif8:
    cmp x0, #9
    bne elseif9
    bl show_credits
    b endif
    elseif9:
    cmp x0, #0
    bne main_loop2 //invalid command
    mov w1, wzr //ret 0
    b end_main
    endif: //just for performance
    b main_loop2
    end_main:
    mov x0, x19
    bl free //free memptr
    end_main_no_alloc:
    mov w0, w1 //ret w1
    ldr x19, [sp], #16
    ldp x29, x30, [sp], #16
    ret
    .size main, (. - main)

.type read_int, %function
.global read_int
read_int: //read a 2byte int in tmp_int and ret the 2byte int 
    stp x29, x30, [sp, #-16]!

    //in PROMPT_STR ptr
    //ret 2byte int

    mov x1, x0
    adr x0, pfmt_str
    bl printf //print prompt

    adr x0, sfmt_2byte_int
    adr x1, tmp_int
    bl scanf //read 2byte int

    adr x0, tmp_int
    ldrh w0, [x0] //ret 2byte int
    ldp x29, x30, [sp], #16
    ret
    .size read_int, (. - read_int)

.type read_str, %function
.global read_str
read_str: //read a str up to 1023 chars and ret the ptr
    stp x29, x30, [sp, #-16]!

    //in PROMPT_STR ptr
    //ret ptr to tmp_str

    mov x1, x0
    adr x0, pfmt_str
    bl printf //print prompt

    adr x0, sfmt_str
    adr x1, tmp_str
    bl scanf //read a str up to 1023 chars

    adr x0, tmp_str //ret ptr to tmp_str
    ldp x29, x30, [sp], #16
    ret
    .size read_str, (. - read_str)

.type sel_playlist, %function
.global sel_playlist
sel_playlist: //Select a playlist w a filename (if it doesn't exist it is created)
    stp x29, x30, [sp, #-16]!

    //input tmp_str with a possible filename
    //ret memptr

    adr x0, n_music
    strh wzr, [x0] //set n_music to 0
    adr x0, n_max_music
    strh wzr, [x0] //set n_max_music to 0

    /*
    str wzr, [x0] //str wzr in n_music and n_max_music
    */

    adr x0, tmp_str
    adr x1, FLNAME_EXT_STR
    bl strcat //add file extension to tmp_str

    mov x1, x0
    adr x0, filename
    bl strcpy //copy tmp_str to filename

    adr x1, file_r_str
    bl fopen //open file \filename for read

    cmp x0, #0 //if not exists
    bne fexist
    ldr x0, =additional_space
    adr x1, n_max_music
    strh w0, [x1] //n_max_music = additional_space
    ldr x1, =music_size
    mul x0, x0, x1 //x0 = space in bytes of \additional_space music
    bl malloc

    b end_sel_playlist

    fexist:
    bl load_data //load music from file and ret memptr

    end_sel_playlist:
    ldp x29, x30, [sp], #16
    ret
    .size sel_playlist, (. - sel_playlist)

.type del_playlist, %function
.global del_playlist
del_playlist: //delete an opened playlist file
    stp x29, x30, [sp, #-16]!

    //ret 0 if success

    adr x0, filename
    adr x1, file_r_str
    bl fopen
    
    cmp x0, #0
    beq end_del_playlist

    bl fclose

    adr x0, filename
    bl remove //delete the file \filename

    end_del_playlist:
    ldp x29, x30, [sp], #16
    ret
    .size del_playlist, (. - del_playlist)

.type load_data, %function
.global load_data
load_data: //load music from file in mem and ret memptr
    stp x29, x30, [sp, #-16]!
    stp x19, x20, [sp, #-16]!
    
    //input fileptr
    //ret memptr
    //x19 memptr
    //x20 fileptr

    mov x20, x0 //save fileptr
    mov x3, x0 
    adr x0, n_music
    ldr x1, =size_music_pos
    ldr x2, =1
    bl fread //read first \size_music_pos byte

    adr x0, n_music
    ldrh w0, [x0]
    add x0, x0, additional_space
    adr x1, n_max_music
    strh w0, [x1]
    ldr x1, =music_size
    mul x0, x0, x1 //x0 = space in bytes of \n_max_music music
    bl malloc
    cmp x0, #0 //if alloc success
    beq end_load_data
    mov x19, x0 //save memptr

    ldr x1, =music_size
    adr x2, n_music
    ldrh w2, [x2]
    mov x3, x20
    bl fread //read all music and put in memptr

    mov x0, x20
    bl fclose //close file

    mov x0, x19 //ret memptr
    end_load_data:
    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16
    ret
    .size load_data, (. - load_data)

.type draw_table, %function
.global draw_table
draw_table: //draw table with the music
    stp x29, x30, [sp, #-16]!
    stp x19, x20, [sp, #-16]!
    stp x21, x22, [sp, #-16]!

    //input memptr
    //x19 memptr
    //x20 n_music val
    //x21 counter
    //x22 subcounter (for stability)

    mov x19, x0 //save memptr
    printm pfmt_str, BORDER_HORIZ_STR
    printm pfmt_str, BORDER_FMT_HEADER_STR
    printm pfmt_str, BORDER_HORIZ_STR
    mov x21, #0 //counter = 0 (actually start with 1, but it was done this way to avoid 1 branch in case of pos not found)
    adr x0, n_music
    ldrh w20, [x0] //save n_music

    draw_table_loop1:
    add w21, w21, #1 //++counter
    cmp x21, x20 //while counter <= n_music
    bgt draw_table_end_loop1
    mov x7, x19 //save memptr for sub cycle
    mov w22, #1

    draw_table_loop2:
    ldrh w1, [x7, offset_music_pos] //load pos value
    cmp x1, x21 //if pos value != counter
    beq draw_table_end_loop2
    add w22, w22, #1 //++subcounter
    cmp x22, x20 //if subcounter <= n_music
    bgt draw_table_loop1
    add x7, x7, music_size //continue search
    b draw_table_loop2
    draw_table_end_loop2:

    adr x0, BORDER_VERT_STR
    add x1, x7, offset_music_pos
    ldrh w1, [x1]
    add x2, x7, offset_music_artist
    add x3, x7, offset_music_title
    ldrb w4, [x7, offset_music_duration_minutes]
    ldrb w5, [x7, offset_music_duration_seconds]
    bl printf //print a row of table
    printm pfmt_str, BORDER_HORIZ_STR
    b draw_table_loop1
    draw_table_end_loop1:

    printm pfmt_str, NEWLINE2_STR
    ldp x21, x22, [sp], #16
    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16
    ret
    .size draw_table, (. - draw_table)

.type save_data, %function
.global save_data
save_data: //save music from mem to file and ret exec code
    stp x29, x30, [sp, #-16]!
    stp x19, x20, [sp, #-16]!

    //input memptr
    //ret exec code
    //x19 memptr
    //x20 fileptr

    mov x19, x0 //save memptr
    adr x0, filename
    adr x1, file_w_str
    bl fopen //open file \filename for write

    cmp x0, #0 //if file is opened
    beq error_save_data
    mov x20, x0 //save fileptr

    mov x3, x20
    adr x0, n_music
    ldr x1, =size_music_pos
    ldr x2, =1
    bl fwrite //write \n_music to file

    mov x0, x19
    ldr x1, =music_size
    adr x2, n_music
    ldrh w2, [x2]
    mov x3, x20
    bl fwrite //write \n_music music in mem to file

    mov x0, x20
    bl fclose //close file

    mov w0, wzr
    b end_save_data
    error_save_data:
    printm pfmt_str, ERROR_FILE_SAVE_STR
    bl presskey
    mov w0, #1
    end_save_data:
    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16
    ret
    .size save_data, (. - save_data)


.type add_music, %function
.global add_music
add_music: //add a new music to mem and save all to file, ret memptr
    stp x29, x30, [sp, #-16]!
    stp x19, x20, [sp, #-16]!
    stp x21, x22, [sp, #-16]!
    str x23, [sp, #-16]!

    //input memptr
    //ret memptr (can be different because of reallocation)
    //x19 memptr
    //x20 memptr for next writing
    //x21 n_music val
    //x22 n_max_music ptr
    //x23 tmp_memptr for next writing

    mov x19, x0 //save memptr
    adr x0, n_music
    ldrh w21,[x0]

    adr x22, n_max_music

    ldrh w1, [x22]
    cmp x21, x1 //if n_music == n_max_music
    bne no_realloc

    mov x0, x19
    ldr x1, =music_size
    add x2, x21, additional_space
    strh w2, [x22] //n_max_music = n_music + additional_space
    mul x1, x2, x1 //x1 = size in bytes of \n_music + \additional_space music
    bl realloc
    mov x19, x0 //save new memptr

    cmp x0, #0
    beq end_add_music

    no_realloc: //space is available in mem
    ldr x0, =music_size
    mul x0, x21, x0
    add x20, x19, x0 //x20 = (n_music * music_size) + memptr

    clear_screen
    printm pfmt_str, INTRO_STR
    printm FMT_CURRENT_PLAYLIST_STR, filename
    mov x0, x19
    bl draw_table

    adr x0, n_music
    add x21, x21, #1
    strh w21, [x0] //n_music += 1

    str x21, [x20, offset_music_pos] //str pos of new music

    adr x0, PROMPT_ARTIST_STR
    bl read_str
    save_to x20, offset_music_artist, size_music_artist //str artist of new music

    adr x0, PROMPT_TITLE_STR
    bl read_str
    save_to x20, offset_music_title, size_music_title //str title of new music

    add x20, x20, offset_music_duration_minutes
    reask:
    mov x23, x20
    adr x0, PROMPT_DURATION_STR
    bl read_str
    adr x1, DURATION_SPLITTER_STR
    bl strtok //split time str in minutes str and seconds str
    b add_music_loopcond1
    add_music_loop1:
    bl atoi //convert str at ptr in int
    cmp x0, #0 //min time
    blt reask
    cmp x0, #59 //max time
    bgt reask
    strb w0, [x23], size_music_duration //str minutes or seconds
    mov x0, #0
    adr x1, DURATION_SPLITTER_STR
    bl strtok //call w/arg0 NULL, arg1 splitter
    add_music_loopcond1:
    cmp x0, #0
    bne add_music_loop1

    mov x0, x19
    bl save_data

    end_add_music:
    mov x0, x19
    ldr x23, [sp], #16
    ldp x21, x22, [sp], #16
    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16
    ret
    .size add_music, (. - add_music)

.type del_music, %function
.global del_music
del_music: //delete a music from mem and save all to file, ret memptr
    stp x29, x30, [sp, #-16]!
    stp x19, x20, [sp, #-16]!
    str x21, [sp, #-16]!

    //in memptr
    //ret memptr (if we add partial deallocation with realloc)
    //x19 memptr
    //x20 n_music ptr
    //x21 selected position

    mov x19, x0 //save memptr

    clear_screen
    printm pfmt_str, INTRO_STR
    printm FMT_CURRENT_PLAYLIST_STR, filename
    mov x0, x19
    bl draw_table

    adr x0, PROMPT_DEL_MUSIC_STR
    bl read_str
    bl isint
    cmp x0, #0
    bne end_del_music
    adr x0, tmp_str
    bl atoi

    cmp x0, xzr
    ble end_del_music

    adr x20, n_music
    ldrh w4, [x20] //save n_music

    mov x21, x0 //save selected position

    mov x2, #1 //counter = 1
    mov x3, x19 //tmp_memptr

    del_music_loop1:
    cmp x2, x4 //if counter <= n_music
    bgt end_del_music
    ldrh w5, [x3, offset_music_pos] //load pos value
    cmp x5, x0 //if pos value != pos selected
    beq del_music_end_loop1
    add x2, x2, #1 //++counter
    add x3, x3, music_size //tmp_memptr += music_size
    b del_music_loop1
    del_music_end_loop1:

    mov x0, x3 //dest
    add x1, x3, music_size //source
    sub x2, x4, x2 //n_music to be copy
    ldr x3, =music_size
    mul x2, x2, x3 //bytes to be copy
    bl memcpy

    ldrh w0, [x20] //n_music
    sub w0, w0, #1 //--n_music
    strh w0, [x20]

    adr x5, n_max_music
    ldrh w2, [x5]
    sub x3, x2, x0 //n_music available space
    sub x3, x3, additional_space
    cmp x3, #0 //if (n_max_music - n_music - additional_space) > 0
    ble adjustpos

    mov x0, x19
    ldr x4, =music_size
    mul x6, x3, x4 //bytes of music in plus additional
    mul x1, x2, x4 //bytes of n_max_music
    sub x1, x1, x6 //bytes to realloc
    sub w2, w2, w3 //n_max_music -= music in plus additional
    strh w2, [x5]
    bl realloc
    mov x19, x0
    cmp x0, #0
    beq end_del_music

    del_music_endif1:
    //Now that one music has been taken away you will have a hole in one position. You have to move each pos higher than the removed by -1
    adjustpos:
    mov x0, x19
    mov x1, #1 //counter = 1
    ldrh w2, [x20] //n_music val

    b del_music_loopcond2
    del_music_loop2:
    ldrh w3, [x0, offset_music_pos] //2byte value at address x0 + offset_music_pos

    cmp x3, x21 //if pos value > selected pos value
    blt del_music_endif2

    sub w3, w3, #1
    strh w3, [x0, offset_music_pos]

    del_music_endif2:
    add x0, x0, music_size
    add w1, w1, #1
    del_music_loopcond2:
    cmp x1, x2
    ble del_music_loop2

    mov x0, x19
    bl save_data

    end_del_music:
    mov x0, x19
    ldr x21, [sp], #16
    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16
    ret
    .size del_music, (. - del_music)


.type findmusic, %function
.global findmusic
findmusic: //Perform a linear search of all music with a given substring in title
    stp x29, x30, [sp, #-16]!
    stp x19, x20, [sp, #-16]!
    stp x21, x22, [sp, #-16]!
    str x23, [sp, #-16]!

    //in memptr
    //x19 memptr
    //x20 n_music val
    //x21 counter
    //x22 subcounter
    //x23 tmp_memptr with pos in order


    mov x19, x0 //save memptr
    adr x0, n_music
    ldrh w20, [x0]
    cmp w20, wzr //if n_music != 0
    beq end_findmusic

    clear_screen
    printm pfmt_str, INTRO_STR
    printm FMT_CURRENT_PLAYLIST_STR, filename
    printm pfmt_str, NEWLINE_STR

    adr x0, PROMPT_FIND_MUSIC_STR
    bl read_str
    printm pfmt_str, NEWLINE_STR
    printm pfmt_str, BORDER_HORIZ_STR
    printm pfmt_str, BORDER_FMT_HEADER_STR
    printm pfmt_str, BORDER_HORIZ_STR

    mov x21, #0 //counter = 0 (vedi draw_table)

    b findmusic_loopcond1
    findmusic_loop1: //loop for print in order
    mov x22, #1 //subcounter = 1 (from 1 to n_music])
    mov x2, x19 //tmp_memptr

    b findmusic_loopcond2
    findmusic_loop2: //loop for find title
    add w22, w22, #1 //++subcounter
    cmp x22, x20 //if subcounter <= n_music
    bgt findmusic_loopcond1
    add x2, x2, music_size //tmp_memptr += music_size
    findmusic_loopcond2:
    ldrh w0, [x2, offset_music_pos]
    cmp x0, x21 //if pos value != searched pos
    bne findmusic_loop2

    //Only positions in line with existing counter come here
    mov x23, x2 //save tmp_memptr
    add x0, x2, offset_music_title //tmp_memptr += offset_music_title
    adr x1, tmp_str
    bl strstr
    cmp x0, xzr //if music title at tmp_memptr + offset_music_title contains searched string
    beq findmusic_loopcond1
    adr x0, BORDER_VERT_STR //see draw_table
    add x1, x23, offset_music_pos
    ldrh w1, [x1]
    add x2, x23, offset_music_artist
    add x3, x23, offset_music_title
    ldrb w4, [x23, offset_music_duration_minutes]
    ldrb w5, [x23, offset_music_duration_seconds]
    bl printf //print a row of table
    printm pfmt_str, BORDER_HORIZ_STR
    findmusic_loopcond1:
    add w21, w21, #1
    cmp x21, x20 //if counter <= n_music
    ble findmusic_loop1
    findmusic_end_loop1:

    //hold table on screen
    bl presskey

    end_findmusic:
    ldr x23, [sp], #16
    ldp x21, x22, [sp], #16
    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16
    ret
    .size findmusic, (. - findmusic)         

.type shuffle, %function
.global shuffle
shuffle: //Shuffle all the music randomically
    stp x29, x30, [sp, #-16]!
    stp x19, x20, [sp, #-16]!
    stp x21, x22, [sp, #-16]!
    str x23, [sp, #-16]!

    //in memptr
    //x19 memptr
    //x20 n_music
    //x21 first selected music ptr
    //x22 second selected music ptr
    //x23 number of shuffle todo

    mov x19, x0 //save memptr
    adr x0, n_music
    ldrh w20, [x0] //save n_music

    cmp w20, #1 //if n_music > 1
    ble end_shuffle

    ldr x0, =shuffle_multiplier
    mul x23, x20, x0 //save number of shuffle
    sub x23, x23, #1 //so x23 is odd and if there are only two musics he can reverse them
    mov x0, xzr
    bl time
    bl srand //set seed for random number

    shuffle_loop1:
    bl rand
    //x21 = (x0 % x20)     range[0, n_music)
    udiv x1, x0, x20
    msub x21, x1, x20, x0 //x0-x1*x20
    shuffle_loop2:
    bl rand
    udiv x1, x0, x20
    msub x22, x1, x20, x0
    cmp x21, x22
    beq shuffle_loop2
    //calculating tmp_memptr for music1 and music2
    ldr x0, =music_size
    mul x1, x0, x21
    add x21, x19, x1 //x21 = memptr + music_size*(selected music1)       0 =< selected music < n_music
    mul x1, x0, x22
    add x22, x19, x1 //x22 = memptr + music_size*(selected music2)
    ldrh w1, [x21, offset_music_pos]
    ldrh w2, [x22, offset_music_pos]
    strh w2, [x21, offset_music_pos]
    strh w1, [x22, offset_music_pos]
    sub x23, x23, #1
    cmp x23, #0
    bgt shuffle_loop1

    mov x0, x19
    bl save_data

    end_shuffle:
    ldr x23, [sp], #16
    ldp x21, x22, [sp], #16
    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16
    ret
    .size shuffle, (. - shuffle)

.type gettotaltime, %function
.global gettotaltime
gettotaltime: //Calculate total time (recursively) of the playlist and print it
    stp x29, x30, [sp, #-16]!
    stp x19, x20, [sp, #-16]!
    str x21, [sp, #-16]!

    //in memptr, counter, n_music val       (x0, x1, x2)
    //x19 memptr
    //x20 total minutes
    //x21 total seconds

    cmp x1, #0 //if first time setup some register
    bne gettotaltime_endif1
    mov x19, x0
    adr x2, n_music
    ldrh w2, [x2]
    mov x3, xzr
    mov x4, xzr
    cmp w2, #0
    beq gettotaltime_else2
    gettotaltime_endif1:

    ldrb w5, [x0, offset_music_duration_minutes]
    add x3, x3, x5 //update total minutes
    ldrb w5, [x0, offset_music_duration_seconds]
    add x4, x4, x5 //update total seconds

    sub x5, x2, #1
    cmp x1, x5 //if not last step continue to recall itself
    beq gettotaltime_else2

    add x0, x0, music_size //memptr += music_size
    add x1, x1, #1 //++counter
    bl gettotaltime
    b gettotaltime_endif2
    gettotaltime_else2:

    //convert excess seconds in minutes
    ldr x1, =60
    udiv x0, x4, x1 //minutes
    msub x1, x0, x1, x4 //seconds
    add x3, x3, x0
    mov x4, x1


    mov x20, x3 //move total minutes in x20
    mov x21, x4 //move total seconds in x21

    clear_screen
    printm pfmt_str, INTRO_STR
    mov x0, x19
    bl draw_table
    mov x0, x20 //total minutes
    mov x1, x21 //total seconds
    ucvtf d0, x0 //cast minutes to fp
    ucvtf d1, x1 //cast seconds to fp
    adr x2, MAXSECONDS_FP
    ldr d2, [x2]
    fdiv d2, d1, d2 //total seconds in minutes
    fadd d0, d0, d2 //total time in minutes

    print_duration TOTALTIME_STR
    
    bl presskey

    gettotaltime_endif2:
    
    ldr x21, [sp], #16
    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16
    ret
    .size gettotaltime, (. - gettotaltime)

.type getavgtime, %function
.global getavgtime
getavgtime: //Calculate average time of the playlist and print it
    stp x29, x30, [sp, #-16]!
    stp x19, x20, [sp, #-16]!
    stp x21, x22, [sp, #-16]!

    //in memptr
    //x0 memptr
    //x1 counter
    //x3 tmp
    //x4 total minute
    //x5 total seconds
    //x19 memptr
    //x20 avg minutes
    //x21 avg seconds
    //x22 n_music val

    mov x19, x0 //save memptr

    clear_screen
    printm pfmt_str, INTRO_STR
    mov x0, x19
    bl draw_table

    adr x2, n_music
    ldrh w22, [x2] //n_music val
    mov x4, xzr
    mov x5, xzr
    cmp x22, xzr
    beq getavgtime_endif1

    mov x0, x19
    getavgtime_loop1:
    ldrb w3, [x0, offset_music_duration_minutes]
    add x4, x4, x3
    ldrb w3, [x0, offset_music_duration_seconds]
    add x5, x5, x3
    add x1, x1, #1 //++counter
    add x0, x0, music_size //memptr += music_size
    cmp x1, x22
    blt getavgtime_loop1

    getavgtime_endif1:
    mov x20, x4 //save total minutes
    mov x21, x5 //save total seconds

    ucvtf d0, x20 //cast total minutes to fp
    ucvtf d1, x21 //cast total seconds to fp
    cmp x22, xzr
    beq getavgtime_endif2
    ucvtf d2, x22 //cast n_music val to fp
    fdiv d0, d0, d2 //avg minutes
    fdiv d1, d1, d2 //avg seconds
    getavgtime_endif2:
    adr x2, MAXSECONDS_FP
    ldr d2, [x2] //d2 = 60.0
    fdiv d1, d1, d2 //avg seconds to minutes
    fadd d0, d0, d1 //avg time in minutes
    fcvtzu x0, d0 //x0 = avg minutes
    ucvtf d1, x0 //d1 = avg minutes
    fsub d1, d0, d1 //d1 = avg seconds in minutes
    fmul d1, d1, d2 //d1 = avg seconds
    fcvtzu x1, d1 //x1 = avg seconds

    print_duration AVGTIME_STR
    bl presskey

    ldp x21, x22, [sp], #16
    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16
    ret
    .size getavgtime, (. - getavgtime)

.type show_credits, %function
.global show_credits
show_credits: //Show the credits room
    stp x29, x30, [sp, #-16]!
    stp x19, x20, [sp, #-16]!
    stp x21, x22, [sp, #-16]!

    //x19 address of first img
    //x20 tmp address of first img
    //x21 counter
    //x22 subcounter

    adr x19, IMG_0
    mov x21, xzr

    //Animation part
    show_credits_loop1:
    mov x22, xzr
    mov x20, x19
    show_credits_loop2:
    clear_screen
    adr x0, pfmt_str
    mov x1, x20
    bl printf
    printm pfmt_str, CREDITS_STR
    ldr x0, =ANIMATION_DELAY
    bl delay
    add x20, x20, IMG_CREDITS_SIZE
    add x22, x22, #1
    cmp x22, #9 //if a full animation is printed
    blt show_credits_loop2

    add x21, x21, #1
    cmp x21, REPEAT_CREDITS
    blt show_credits_loop1

    bl presskey

    ldp x21, x22, [sp], #16
    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16
    ret
    .size show_credits, (. - show_credits)

.type presskey, %function
.global presskey
presskey: //Wait until \n is pressed
    stp x29, x30, [sp, #-16]!

    printm pfmt_str, PROMPT_PRESS_KEY_STR
    bl getchar
    presskey_loop1:
    bl getchar
    cmp x0, '\n'
    bne presskey_loop1

    ldp x29, x30, [sp], #16
    ret
    .size presskey, (. - presskey)

.type delay, %function
.global delay
delay: //Delay execution of a number of ticks
    stp x29, x30, [sp, #-16]!
    stp x19, x20, [sp, #-16]!

    //in tick to delay
    //x19 tick to delay
    //x20 start time

    mov x19, x0 //save tick to delay
    bl clock //get start time
    mov x20, x0 //save start time

    delay_loop1:
    bl clock
    add x1, x19, x20
    cmp x0, x1
    blt delay_loop1

    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16
    ret
    .size delay, (. - delay)

.type isint, %function
.global isint
isint: //Check if a str is a valid int
    stp x29, x30, [sp, #-16]!

    //in str pointer
    //ret 0 if str is valid int

    //x0 = tmpchar
    mov x1, x0

    ldrb w0, [x1]
    cmp w0, '-'
    bne isint_loop1
    add x1, x1, #1

    isint_loop1:
    ldrb w0, [x1], #1
    cmp w0, '0'
    blt end_isint
    cmp w0, '9'
    bgt end_isint
    b isint_loop1

    end_isint:
    ldp x29, x30, [sp], #16
    ret
    .size isint, (. - isint)
