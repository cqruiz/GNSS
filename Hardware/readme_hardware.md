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

## 7) Hardware and Software

* **Receptor Hardware:**
  
  GNSS receptor/ u-blox Receiver  
  - https://www.sparkfun.com/sparkfun-gps-rtk2-board-zed-f9p-qwiic-gps-15136.html
  - https://es.aliexpress.com/item/1005007991451892.html?spm=a2g0o.tesla.0.0.3f17zwMXzwMXMJ&afTraceInfo=1005007991451892__pc__c_ppc_item_bridge_pc_main__6Jbb8Aa__1762820595680&gatewayAdapt=glo2esp
 
  GNSS Antenna
  - https://www.sparkfun.com/u-blox-multi-band-active-gnss-antenna-l1-l5-ann-mb5.html
 
* **Receptor Transmitter:**

  - HackRF Uno: https://greatscottgadgets.com/hackrf/one/
    For more information please go to the Reference Papper (GNSS interference and spoofing dataset ) in section 4. Experimental Design, Materials and Methods: (https://www.sciencedirect.com/science/article/pii/S2352340924002713?ref=pdf_download&fr=RR-2&rr=90ca5490ce63eda7)
| Radio Node                 | Parameter                         | Description                                                                       |
| -------------------------- | --------------------------------- | --------------------------------------------------------------------------------- |
| HackRF One transmiter node | Antenna                           | Antenna type                                                                      |
| HackRF One transmiter node | Antenna type                      | 2G, 3G, 4G suction cup antenna, HackRF One applicable SMA internal needle antenna |
| HackRF One transmiter node | Connector Type                    | SMA female thread female pin                                                      |
| HackRF One transmiter node | Antenna Gain                      | 12dbi                                                                             |
| HackRF One transmiter node | Antenna Height                    | 310mm                                                                             |
| HackRF One transmiter node | Feeder Length                     | 3 m                                                                               |
| HackRF One transmiter node | Operating Frequency               | 700MHZ-2700MHZ                                                                    |
| HackRF One transmiter node | Impedance                         | 50Ω                                                                               |
| HackRF One transmiter node | Voltage Standing Wave Ratio(VSWR) | ≤1.8                                                                              |
| HackRF One transmiter node | Polarisation                      | Horizontal                                                                        |
| HackRF One                 | Frequency Band                    | 1MHz-6GHz                                                                         |
| HackRF One                 | RF Bandwidth                      | 20MHz                                                                             |
| HackRF One                 | Maximum Transmit Power            | 15dBm                                                                             |
| HackRF One                 | Maximum Received Power            | -5dBm                                                                             |

 
* **Software:**

  - GPS-SDR-SIM: GPS-SDR-SIM generates GPS baseband signal data streams, which can be converted to RF using software-defined radio (SDR) platforms (https://github.com/osqzss/gps-sdr-sim)
  
 
  
