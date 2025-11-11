# Hardware and Connections for Generating the GNSS Dataset (README-ready Summary)

> **TL;DR**: The bench includes **GNSS antenna → u-blox receiver → computer (logger)** to capture authentic signals, plus **OTA emitters** (a **HackRF One** for *spoofing* and a **commercial jammer** for *jamming*) that radiate over the air toward the victim’s same antenna.

## 1) Hardware Used

| Component                  | Role in the experiment                         | Main connections                 | Notes                                                       |
| -------------------------- | ---------------------------------------------- | -------------------------------- | ----------------------------------------------------------- |
| **GNSS antenna**           | Captures authentic GNSS signals                | RF coax → *u-blox receiver*      | Outdoor/open-sky installation for good visibility.          |
| **u-blox GNSS receiver**   | Front-end + tracking + observables/data output | USB/Serial/Ethernet → *Computer* | The paper does not specify the exact model; see Section 3.  |
| **Computer / data logger** | Data logging and synchronization               | From u-blox (USB/Serial)         | Stores dataset files (raw/processed, per the publication).  |
| **SDR HackRF One**         | Generates *spoofing* (fake signals)            | TX via antenna → OTA             | Over-the-air transmission toward the victim’s GNSS antenna. |
| **Commercial jammer**      | Generates *jamming* (interference)             | TX via antenna → OTA             | Over-the-air transmission toward the victim’s GNSS antenna. |

> **Note:** In the described setup there is **no direct cabling** between the emitters (HackRF/jammer) and the victim receiver; everything enters **through the same GNSS antenna**.

## 2) Topology & Signal Flow (Block Diagram)

```txt
[GNSS Satellites (authentic)]
            |
            v   (over-the-air propagation)
+-----------------------+
|       GNSS Antenna    |
+-----------------------+
            |  (RF coax)
            v
+-----------------------+
|     u-blox Receiver   |
+-----------------------+
            |  (USB/Serial/Ethernet)
            v
+-------------------------------+
|   Computer / Data Logger      |
|   (logging and processing)    |
+-------------------------------+
            |
            v
        [Dataset files]
```

**OTA interference (injection over the same RF channel):**

```txt
[HackRF One + TX ant.]  --->\
                              \        (mixing in the air)
                               >-----> [GNSS Antenna] ---> [u-blox] ---> [Logger]
[Commercial jammer + TX] --->/
```

## 3) Which u-blox model was used?

* The article/dataset **does not specify the exact model**; it only states “a u-blox GNSS receiver.”
* Given the reported multi-constellation and multi-frequency coverage and the cited technical references, it is **very likely** from the **u-blox F9 family** (e.g., ZED-F9P/F9R).

## 4) Experimental Operating Mode

1. The **victim chain** (GNSS antenna → u-blox → computer) records continuously.
2. **OTA emitters** (HackRF One and commercial jammer) transmit *spoofing* and *jamming* signals over the air to perturb/deceive the receiver.
3. The logger stores the resulting data as part of the **dataset**.

## 5) Observables & Logs (High Level)

* The publication reports **multi-GNSS observations** and typical diagnostic/logging messages (e.g., `RAWX`, `PVT`, `MON-SPAN`, depending on the capture setup).
* It also describes the **test environment** and **OTA configuration** (HackRF and jammer) as part of the experimental protocol.

> For exact details of **messages, rates, and bands**, see the Methods section and the article’s dataset repository.

## 6) Reproducibility (Quick Guidelines)

* Use a **GNSS antenna** outdoors or with open sky, connected to a modern **u-blox receiver**.
* Connect the **u-blox** to a **logging machine** (PC/embedded) that saves both observables and status messages.
* Use an **SDR** (e.g., HackRF One) for *spoofing* and a **jammer** for *jamming* **only in controlled environments** and with **regulatory permission** (legal compliance and operational safety).

## 7) Main Reference

* **Dataset article**: *Data in Brief* (Elsevier). Link provided by the user:
  [https://www.sciencedirect.com/science/article/pii/S2352340924002713](https://www.sciencedirect.com/science/article/pii/S2352340924002713)

* **u-blox documentation (example):** *u-blox F9 High Precision GNSS – Interface Description (HPS)* (to understand UBX messages such as `RAWX`, `PVT`, etc.).
