#include <linux/init.h>
#include <linux/module.h>
#include <linux/netdevice.h>

MODULE_LICENSE("GPL-2.0");

struct net_device *dev; // FIXME: Stupid

static int untitled_open(struct net_device *dev)
{
	printk(KERN_ALERT "untitled: open\n");
	return 0;
}

static int untitled_stop(struct net_device *dev)
{
	printk(KERN_ALERT "untitled: stop\n");
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

static void untitled_probe(struct net_device *dev)
{
	printk(KERN_ALERT "untitled: probe\n");

	dev->netdev_ops = &untitled_netdev_ops;
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
