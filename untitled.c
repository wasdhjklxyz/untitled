#include <linux/init.h>
#include <linux/module.h>
#include <linux/netdevice.h>
#include <linux/etherdevice.h>

MODULE_LICENSE("GPL-2.0");

#define UNTITLED_TIMEOUT 5 // NOTE: In jiffies

struct net_device *dev; // FIXME: Stupid

static int untitled_open(struct net_device *dev)
{
	printk(KERN_ALERT "untitled: open\n");
	eth_hw_addr_set(dev, "\0UNTITLED"); // NOTE: Fakes a hardware number
	netif_start_queue(dev);
	return 0;
}

static int untitled_stop(struct net_device *dev)
{
	printk(KERN_ALERT "untitled: stop\n");
	netif_stop_queue(dev);
	return 0;
}

static int untitled_start_xmit(struct sk_buff *skb, struct net_device *dev)
{
	printk(KERN_ALERT "untitled: start_xmit\n");
	return 0;
}

static int untitled_do_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
{
	printk(KERN_ALERT "untitled: do_ioctl\n");
	return 0;
}

static int untitled_set_config(struct net_device *dev, struct ifmap *map)
{
	printk(KERN_ALERT "untitled: set_config\n");
	return 0;
}

static struct net_device_stats *untitled_get_stats(struct net_device *dev)
{
	printk(KERN_ALERT "untitled: get_stats\n");
	return NULL;
}

static int untitled_change_mtu(struct net_device *dev, int new_mtu)
{
	printk(KERN_ALERT "untitled: change_mtu\n");
	return 0;
}

static void untitled_tx_timeout(struct net_device *dev, unsigned int txqueue)
{
	printk(KERN_ALERT "untitled: tx_timeout\n");
}

static const struct net_device_ops untitled_netdev_ops = {
	.ndo_open = untitled_open,
	.ndo_stop = untitled_stop,
	.ndo_start_xmit = untitled_start_xmit,
	.ndo_do_ioctl = untitled_do_ioctl,
	.ndo_set_config = untitled_set_config,
	.ndo_get_stats = untitled_get_stats,
	.ndo_change_mtu = untitled_change_mtu,
	.ndo_tx_timeout = untitled_tx_timeout,
};

struct untitled_packet {
	struct untitled_packet *next;
	struct net_device *dev;
	int datalen;
	u8 data[ETH_DATA_LEN];
};

struct untitled_priv {
	struct net_device_stats stats;
	int status;
	struct untitled_packet **ppool;
	struct untitled_packet *rx_queue; // NOTE: List of incoming packets
	int rx_int_enabled;
	int tx_packetlen;
	u8 *tx_packetdata;
	struct sk_buff *skb;
	spinlock_t lock;
};

static void untitled_rx_ints(struct net_device *dev, int enable)
{
	struct untitled_priv *priv = netdev_priv(dev);
	if (!priv) {
		printk(KERN_WARNING
		       "untitled: rx_ints: netdev_priv returned NULL\n");
		return;
	}
	priv->rx_int_enabled = enable;
}

static void untitled_probe(struct net_device *dev)
{
	printk(KERN_ALERT "untitled: probe\n");

	ether_setup(dev);
	dev->watchdog_timeo = UNTITLED_TIMEOUT;
	dev->netdev_ops = &untitled_netdev_ops;
	dev->flags |= IFF_NOARP; // NOTE: We do not have ARP implementation

	struct untitled_priv *priv = netdev_priv(dev);
	if (!priv) {
		printk(KERN_WARNING
		       "untitled: probe: netdev_priv returned NULL\n");
	}
	memset(priv, 0, sizeof(struct untitled_priv));
	spin_lock_init(&priv->lock);
	untitled_rx_ints(dev, 1); // NOTE: Enable receive interrupts
}

static int hello_init(void)
{
	printk(KERN_ALERT "hello world\n");

	dev = alloc_netdev(0, "untitled%d", NET_NAME_UNKNOWN, untitled_probe);
	if (!dev) {
		printk(KERN_ERR "untitled: alloc_netdev\n");
		return -ENOMEM;
	}

	/*
	// TODO: Initialization must be complete before register_netdev()
	int err = register_netdev(dev);
	if (err) {
		printk(KERN_ERR "untitled: register_netdev\n");
		free_netdev(dev);
		return err;
	}
	*/

	return 0;
}

static void hello_exit(void)
{
	printk(KERN_ALERT "goodbye\n");

	// TODO: unregister_netdev(dev);
	free_netdev(dev);
}

module_init(hello_init);
module_exit(hello_exit);
